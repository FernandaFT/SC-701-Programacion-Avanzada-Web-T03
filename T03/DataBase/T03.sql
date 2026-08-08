USE [master]
GO
CREATE DATABASE [PracticaS13]
GO
USE [PracticaS13]

GO
CREATE TABLE [dbo].[Abonos](
	[Id_Compra] [bigint] NOT NULL,
	[Id_Abono] [bigint] IDENTITY(1,1) NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[Fecha] [datetime] NOT NULL,
 CONSTRAINT [PK_Abonos] PRIMARY KEY CLUSTERED 
(
	[Id_Abono] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[Principal](
	[Id_Compra] [bigint] IDENTITY(1,1) NOT NULL,
	[Precio] [decimal](18, 5) NOT NULL,
	[Saldo] [decimal](18, 5) NOT NULL,
	[Descripcion] [varchar](500) NOT NULL,
	[Estado] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Principal] PRIMARY KEY CLUSTERED 
(
	[Id_Compra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Abonos] ON 
GO
INSERT [dbo].[Abonos] ([Id_Compra], [Id_Abono], [Monto], [Fecha]) VALUES (2, 1, CAST(500.00 AS Decimal(18, 2)), CAST(N'2026-08-08T14:13:46.910' AS DateTime))
GO
INSERT [dbo].[Abonos] ([Id_Compra], [Id_Abono], [Monto], [Fecha]) VALUES (5, 2, CAST(480.00 AS Decimal(18, 2)), CAST(N'2026-08-08T14:28:11.817' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Abonos] OFF
GO
SET IDENTITY_INSERT [dbo].[Principal] ON 
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (1, CAST(50000.00000 AS Decimal(18, 5)), CAST(50000.00000 AS Decimal(18, 5)), N'Producto 1', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (2, CAST(13500.00000 AS Decimal(18, 5)), CAST(13000.00000 AS Decimal(18, 5)), N'Producto 2', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (3, CAST(83600.00000 AS Decimal(18, 5)), CAST(83600.00000 AS Decimal(18, 5)), N'Producto 3', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (4, CAST(1220.00000 AS Decimal(18, 5)), CAST(1220.00000 AS Decimal(18, 5)), N'Producto 4', N'Pendiente')
GO
INSERT [dbo].[Principal] ([Id_Compra], [Precio], [Saldo], [Descripcion], [Estado]) VALUES (5, CAST(480.00000 AS Decimal(18, 5)), CAST(0.00000 AS Decimal(18, 5)), N'Producto 5', N'Pagado')
GO
SET IDENTITY_INSERT [dbo].[Principal] OFF
GO
ALTER TABLE [dbo].[Abonos]  WITH CHECK ADD  CONSTRAINT [FK_Abonos_Principal] FOREIGN KEY([Id_Compra])
REFERENCES [dbo].[Principal] ([Id_Compra])
GO
ALTER TABLE [dbo].[Abonos] CHECK CONSTRAINT [FK_Abonos_Principal]

GO
CREATE   PROCEDURE [dbo].[spConsultarCompras]
AS
BEGIN

    SELECT
        Id_Compra AS IdCompra,
        Descripcion
    FROM Principal
    ORDER BY Id_Compra

END

GO
CREATE   PROCEDURE [dbo].[spConsultarDetalleCompras]
AS
BEGIN

    SELECT
        Id_Compra AS IdCompra,
        Descripcion,
        Precio,
        Saldo,
        Estado
    FROM Principal
    ORDER BY Id_Compra

END


GO
CREATE   PROCEDURE [dbo].[spConsultarSaldoCompra]
    @IdCompra BIGINT
AS
BEGIN

    SELECT
        Id_Compra AS IdCompra,
        Saldo AS SaldoAnterior
    FROM Principal
    WHERE Id_Compra = @IdCompra

END

GO
CREATE   PROCEDURE [dbo].[spRegistrarAbono]
    @IdCompra BIGINT,
    @Monto DECIMAL(18,2)
AS
BEGIN

    DECLARE @SaldoActual DECIMAL(18,5)
    DECLARE @NuevoSaldo DECIMAL(18,5)

    SELECT @SaldoActual = Saldo
    FROM Principal
    WHERE Id_Compra = @IdCompra

    IF @SaldoActual IS NULL
    BEGIN
        RAISERROR('La compra seleccionada no existe.', 16, 1)
        RETURN
    END

    IF @Monto <= 0
    BEGIN
        RAISERROR('El monto del abono debe ser mayor a cero.', 16, 1)
        RETURN
    END

    IF @Monto > @SaldoActual
    BEGIN
        RAISERROR('El monto del abono no puede ser mayor al saldo pendiente.', 16, 1)
        RETURN
    END

    SET @NuevoSaldo = @SaldoActual - @Monto

    INSERT INTO Abonos
    (
        Id_Compra,
        Monto,
        Fecha
    )
    VALUES
    (
        @IdCompra,
        @Monto,
        GETDATE()
    )


    UPDATE Principal
    SET Saldo = @NuevoSaldo,
        Estado = CASE
                    WHEN @NuevoSaldo = 0 THEN 'Pagado'
                    ELSE 'Pendiente'
                 END
    WHERE Id_Compra = @IdCompra


    SELECT
        Id_Compra AS IdCompra,
        Saldo AS SaldoAnterior,
        Estado
    FROM Principal
    WHERE Id_Compra = @IdCompra

END
GO
USE [master]
GO
ALTER DATABASE [PracticaS13] SET  READ_WRITE 
GO
