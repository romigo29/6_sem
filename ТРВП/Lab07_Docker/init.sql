USE master;
GO

CREATE DATABASE Celebrities;
GO

USE Celebrities;
GO

CREATE TABLE [dbo].[Celebrities](
    [Id]           [int] IDENTITY(1,1) NOT NULL,
    [FullName]     [nvarchar](50)  NOT NULL,
    [Nationality]  [nvarchar](2)   NOT NULL,
    [ReqPhotoPath] [nvarchar](200) NULL,
    CONSTRAINT [PK_Celebrities] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

-- Тестовые данные (Nationality – ISO 3166-1 alpha-2)
INSERT INTO Celebrities (FullName, Nationality, ReqPhotoPath) VALUES
('Ada Lovelace',  'US', '/photos/lovelace.jpg'),
('Alan Turin', 'US', '/photos/turin.jpg'),
('Igor Sysoev',  'RU', '/photos/sysoev.jpg')
GO

-- Проверочные DML
SELECT * FROM Celebrities;

