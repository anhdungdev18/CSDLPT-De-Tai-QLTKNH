USE [QLTKNH]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateCustomer]    Script Date: 6/10/2025 10:54:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CreateCustomer]
    @idCustomer     VARCHAR(20),
    @CustomerName   NVARCHAR(100),
    @Address        NVARCHAR(255),
    @PhoneNumber    VARCHAR(15),
    @BranchID       VARCHAR(20) = 'BR001'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Kiểm tra trùng mã khách hàng
        IF EXISTS (SELECT 1 FROM Customer WHERE idCustomer = @idCustomer)
        BEGIN
            RAISERROR('idCustomer đã tồn tại.', 16, 1);
            RETURN;
        END

        -- Thêm khách hàng mới
        INSERT INTO Customer(idCustomer, customerName, address, phoneNumber, idBranch)
        VALUES (@idCustomer, @CustomerName, @Address, @PhoneNumber, @BranchID);

        COMMIT TRANSACTION;
        PRINT 'Tạo khách hàng thành công.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ChuyenKhoan]    Script Date: 6/10/2025 10:54:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ChuyenKhoan]
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(18,2),
    @idStaff VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @TranSuccess BIT = 0;

    BEGIN TRY
        BEGIN DISTRIBUTED TRANSACTION;

        -- Kiểm tra tài khoản nguồn
        IF NOT EXISTS (SELECT 1 FROM Account WHERE accountNumber = @FromAccountID)
        BEGIN
            RAISERROR('Tài khoản nguồn không tồn tại.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM LINK0.QLTKNH.dbo.Account WHERE accountNumber = @ToAccountID)
        BEGIN
            RAISERROR('Tài khoản đích không tồn tại trên chi nhánh đích.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        DECLARE @FromBalance DECIMAL(18,2);
        SELECT @FromBalance = Balance FROM Account WHERE accountNumber = @FromAccountID;

        IF @FromBalance < @Amount
        BEGIN
            RAISERROR('Tài khoản nguồn không đủ tiền.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Trừ tiền tại server A
        UPDATE Account
        SET Balance = Balance - @Amount
        WHERE accountNumber = @FromAccountID;

        -- Cộng tiền tại server B
        UPDATE LINK0.QLTKNH.dbo.Account
        SET Balance = Balance + @Amount
        WHERE accountNumber = @ToAccountID;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Tài khoản đích không tồn tại.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @TranSuccess = 1;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();

        -- Nếu cần ghi log lỗi sau này ở local cũng được
        RAISERROR(@ErrMsg, 16, 1);
        RETURN;
    END CATCH

    -- 🔸 Tách ghi log ra ngoài transaction phân tán

   INSERT INTO TransactionInfo (sourceAccountNumber,targerAccountNumber , transactionValue, transactionDate, id_Staff)
    VALUES (
        @FromAccountID,
		@ToAccountID,
        @Amount,
        GETDATE(),
        @idStaff
    );
END
GO
/****** Object:  StoredProcedure [dbo].[sp_Deposit]    Script Date: 6/10/2025 10:54:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Deposit]
    @AccountID VARCHAR(20),
    @Amount DECIMAL(18,2),
    @idStaff VARCHAR(20),
    @idTransaction VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    -- Cập nhật số dư trong bảng Accounts
    UPDATE Account
    SET Balance = Balance + @Amount
    WHERE accountNumber = @AccountID;

    COMMIT TRANSACTION;
	BEGIN TRANSACTION;
    -- Ghi log vào bảng Transactions
    INSERT INTO TransactionInfo (idTransaction, transactionValue, TransactionDate, sourceAccountNumber, id_Staff)
    VALUES (@idTransaction, @Amount, GETDATE(), @AccountID, @idStaff);

    COMMIT TRANSACTION;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetAccountInfo]    Script Date: 6/10/2025 10:54:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetAccountInfo]
    @AccountID VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustomerName NVARCHAR(100);
    DECLARE @Balance INT;
    DECLARE @BranchID VARCHAR(20);
    DECLARE @CreatedDate DATETIME;

    BEGIN TRY
        -- Truy vấn thông tin tài khoản và thông tin chủ tài khoản
        SELECT 
            @CustomerName = c.customerName,
            @Balance = a.Balance,
            @BranchID = c.idBranch,
            @CreatedDate = a.startDate
        FROM 
            Account a
        JOIN 
            Customer c ON a.id_Customer = c.idCustomer
        WHERE 
            a.accountNumber = @AccountID;

        -- Kiểm tra nếu không tìm thấy tài khoản
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(N'Tài khoản không tồn tại.', 16, 1);
            RETURN;
        END

        -- In ra thông tin tài khoản
        PRINT N'Thông tin tài khoản:';
        PRINT N'Mã tài khoản: ' + @AccountID;
        PRINT N'Tên chủ tài khoản: ' + @CustomerName;
        PRINT N'Số dư: ' + CAST(@Balance AS NVARCHAR(20));
        PRINT N'Chi nhánh: ' + CAST(@BranchID AS NVARCHAR(10)) ;
        PRINT N'Ngày tạo: ' + CONVERT(NVARCHAR(20), @CreatedDate, 120); -- Định dạng YYYY-MM-DD HH:MI:SS
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetServerAccountInfo]    Script Date: 6/10/2025 10:54:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetServerAccountInfo]
    @AccountID VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustomerName NVARCHAR(100);
    DECLARE @Balance INT;
    DECLARE @BranchID VARCHAR(20);
    DECLARE @CreatedDate DATETIME;

    BEGIN TRY
        -- Truy vấn thông tin tài khoản và thông tin chủ tài khoản
        SELECT 
            @CustomerName = c.customerName,
            @Balance = a.Balance,
            @BranchID = c.idBranch,
            @CreatedDate = a.startDate
        FROM 
            [LINK0].[QLTKNH].[dbo].[Account] a
        JOIN 
            [LINK0].[QLTKNH].[dbo].[Customer] c ON a.id_Customer = c.idCustomer
        WHERE 
            a.accountNumber = @AccountID;

        -- Kiểm tra nếu không tìm thấy tài khoản
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(N'Tài khoản không tồn tại.', 16, 1);
            RETURN;
        END

        -- In ra thông tin tài khoản
        PRINT N'Thông tin tài khoản:';
        PRINT N'Mã tài khoản: ' + @AccountID;
        PRINT N'Tên chủ tài khoản: ' + @CustomerName;
        PRINT N'Số dư: ' + CAST(@Balance AS NVARCHAR(20));
        PRINT N'Chi nhánh: ' + CAST(@BranchID AS NVARCHAR(10)) ;
        PRINT N'Ngày tạo: ' + CONVERT(NVARCHAR(20), @CreatedDate, 120); -- Định dạng YYYY-MM-DD HH:MI:SS
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
CREATE PROCEDURE [dbo].[sp_TransferAndRecordTransaction]
    @FromAccountID VARCHAR(20),
    @ToAccountID VARCHAR(20),
    @Amount INT,
	@idStaff VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

	SET XACT_ABORT ON;

    DECLARE @FromBalance INT;
    DECLARE @ToBalance INT;

    BEGIN TRY
        -- Kiểm tra số dư tài khoản nguồn
        SELECT @FromBalance = Balance 
        FROM [LINK0].[QLTKNH].[dbo].[Account] 
        WHERE accountNumber = @FromAccountID;

        IF @FromBalance IS NULL
        BEGIN
            RAISERROR(N'Tài khoản nguồn không tồn tại.', 16, 1);
            RETURN;
        END

        IF @FromBalance < @Amount
        BEGIN
            RAISERROR(N'Số dư tài khoản nguồn không đủ để thực hiện chuyển khoản.', 16, 1);
            RETURN;
        END

        -- Kiểm tra tài khoản đích trên linked server
        SELECT @ToBalance = Balance 
        FROM [LINK0].[QLTKNH].[dbo].[Account] 
        WHERE accountNumber = @ToAccountID;

        IF @ToBalance IS NULL
        BEGIN
            RAISERROR(N'Tài khoản đích không tồn tại trên server liên kết.', 16, 1);
            RETURN;
        END

        -- Thực hiện chuyển khoản
        BEGIN TRANSACTION;

        -- Giảm số dư tài khoản nguồn
        UPDATE [LINK0].[QLTKNH].[dbo].[Account]
        SET Balance = Balance - @Amount
        WHERE accountNumber = @FromAccountID;

        -- Tăng số dư tài khoản đích
        UPDATE [LINK0].[QLTKNH].[dbo].[Account]
        SET Balance = Balance + @Amount
        WHERE accountNumber = @ToAccountID;

        -- Ghi lại giao dịch vào bảng TransactionInfo
        INSERT INTO [LINK0].[QLTKNH].[dbo].[TransactionInfo] (sourceAccountNumber,targerAccountNumber, transactionDate, transactionValue, type, id_Staff)
        VALUES (@FromAccountID, @ToAccountID, GETDATE(), -@Amount, 'Chuyen_Khoan', @idStaff); -- Ghi lại giao dịch chuyển tiền đi

        INSERT INTO [LINK0].[QLTKNH].[dbo].[TransactionInfo] (sourceAccountNumber,targerAccountNumber, transactionDate, transactionValue, type, id_Staff)
        VALUES (@FromAccountID, @ToAccountID, GETDATE(), @Amount,'Chuyen_Khoan' , @idStaff); -- Ghi lại giao dịch chuyển tiền đến

        COMMIT TRANSACTION;

        PRINT N'Chuyển khoản thành công!';
        PRINT N'Tài khoản nguồn: ' + @FromAccountID;
        PRINT N'Tài khoản đích: ' + @ToAccountID;
        PRINT N'Số tiền chuyển: ' + CAST(@Amount AS NVARCHAR(20));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END