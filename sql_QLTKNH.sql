USE [QLTKNH]
GO
/****** Object:  Table [dbo].[Account]    Script Date: 6/10/2025 10:51:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[accountNumber] [varchar](20) NOT NULL,
	[balance] [int] NULL,
	[startDate] [date] NULL,
	[id_Customer] [varchar](20) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[accountNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Branch]    Script Date: 6/10/2025 10:51:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Branch](
	[idBranch] [varchar](20) NOT NULL,
	[branchName] [nvarchar](100) NULL,
	[address] [nvarchar](100) NULL,
	[phoneNumber] [varchar](20) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idBranch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Card]    Script Date: 6/10/2025 10:51:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Card](
	[cardNumber] [varchar](20) NOT NULL,
	[expireDate] [date] NULL,
	[id_CardType] [varchar](20) NOT NULL,
	[account_Number] [varchar](20) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[cardNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CardType]    Script Date: 6/10/2025 10:51:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CardType](
	[idCardType] [varchar](20) NOT NULL,
	[typeName] [nvarchar](100) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idCardType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 6/10/2025 10:51:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[idCustomer] [varchar](20) NOT NULL,
	[customerName] [nvarchar](100) NULL,
	[customerDOB] [date] NULL,
	[address] [nvarchar](100) NULL,
	[identifyNumber] [varchar](20) NULL,
	[phoneNumber] [varchar](20) NULL,
	[idBranch] [varchar](20) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idCustomer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staff]    Script Date: 6/10/2025 10:51:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staff](
	[idStaff] [varchar](20) NOT NULL,
	[staffName] [nvarchar](100) NULL,
	[staffDOB] [date] NULL,
	[address] [nvarchar](100) NULL,
	[phoneNumber] [varchar](20) NULL,
	[idBranch] [varchar](20) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idStaff] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionInfo]    Script Date: 6/10/2025 10:51:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionInfo](
	[idTransaction] [varchar](20) NOT NULL,
	[transactionDate] [date] NOT NULL,
	[transactionValue] [int] NOT NULL,
	[sourceAccountNumber] [varchar](20) NULL,
	[targerAccountNumber] [varchar](20) NULL,
	[id_Staff] [varchar](20) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[type] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED 
(
	[idTransaction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Account] ADD  CONSTRAINT [MSmerge_df_rowguid_A2DCFF085C46409DA3FEF6CD2C2D82EF]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[Branch] ADD  CONSTRAINT [MSmerge_df_rowguid_A3204AC1015349138458EC8DCBF0605E]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[Card] ADD  CONSTRAINT [MSmerge_df_rowguid_0EB36E6EAB2F4ED0B63596F4AD6D8662]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[CardType] ADD  CONSTRAINT [MSmerge_df_rowguid_BC0481FF6E1A4B9D94810BD931C0C349]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [MSmerge_df_rowguid_706A7306623144018094E81C3D58500A]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[Staff] ADD  CONSTRAINT [MSmerge_df_rowguid_EC618CB5859048809528E16CECF94ECD]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[TransactionInfo] ADD  CONSTRAINT [DF_idTransaction]  DEFAULT (left(CONVERT([nvarchar](36),newid()),(20))) FOR [idTransaction]
GO
ALTER TABLE [dbo].[TransactionInfo] ADD  CONSTRAINT [MSmerge_df_rowguid_804474D955554706A0698B137D8B9FA8]  DEFAULT (newsequentialid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[TransactionInfo] ADD  DEFAULT ('transferMoney') FOR [type]
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [FK__Account__id_Cust__44FF419A] FOREIGN KEY([id_Customer])
REFERENCES [dbo].[Customer] ([idCustomer])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [FK__Account__id_Cust__44FF419A]
GO
ALTER TABLE [dbo].[Card]  WITH CHECK ADD  CONSTRAINT [FK_Card_Account] FOREIGN KEY([account_Number])
REFERENCES [dbo].[Account] ([accountNumber])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Card] CHECK CONSTRAINT [FK_Card_Account]
GO
ALTER TABLE [dbo].[Card]  WITH CHECK ADD  CONSTRAINT [FK_Card_CardType] FOREIGN KEY([id_CardType])
REFERENCES [dbo].[CardType] ([idCardType])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Card] CHECK CONSTRAINT [FK_Card_CardType]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK__Customer__idBran__3A81B327] FOREIGN KEY([idBranch])
REFERENCES [dbo].[Branch] ([idBranch])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK__Customer__idBran__3A81B327]
GO
ALTER TABLE [dbo].[Staff]  WITH CHECK ADD  CONSTRAINT [FK__Staff__idBranch__3D5E1FD2] FOREIGN KEY([idBranch])
REFERENCES [dbo].[Branch] ([idBranch])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Staff] CHECK CONSTRAINT [FK__Staff__idBranch__3D5E1FD2]
GO
ALTER TABLE [dbo].[TransactionInfo]  WITH CHECK ADD  CONSTRAINT [FK_TransactionInfo_Account] FOREIGN KEY([sourceAccountNumber])
REFERENCES [dbo].[Account] ([accountNumber])
GO
ALTER TABLE [dbo].[TransactionInfo] CHECK CONSTRAINT [FK_TransactionInfo_Account]
GO
ALTER TABLE [dbo].[TransactionInfo]  WITH CHECK ADD  CONSTRAINT [FK_TransactionInfo_Account1] FOREIGN KEY([targerAccountNumber])
REFERENCES [dbo].[Account] ([accountNumber])
GO
ALTER TABLE [dbo].[TransactionInfo] CHECK CONSTRAINT [FK_TransactionInfo_Account1]
GO
ALTER TABLE [dbo].[TransactionInfo]  WITH CHECK ADD  CONSTRAINT [FK_TransactionInfo_Staff] FOREIGN KEY([id_Staff])
REFERENCES [dbo].[Staff] ([idStaff])
GO
ALTER TABLE [dbo].[TransactionInfo] CHECK CONSTRAINT [FK_TransactionInfo_Staff]
GO
