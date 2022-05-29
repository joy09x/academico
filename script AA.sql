SET collation_connection = ucs2_unicode_ci;

DROP TABLE IF EXISTS AARevendas;


CREATE TABLE AARevendas (
	id INT NOT NULL AUTO_INCREMENT,
	regiao VARCHAR(4) NOT NULL,
	estado VARCHAR(4) NULL,
	municipio VARCHAR(40) null,
	revenda VARCHAR(120) null,
	cnpj VARCHAR(30) null,
	cproduto VARCHAR(20) null,
	datacoleta VARCHAR(80) null,
	--  valorvenda VARCHAR(10) null,
	--  valorcompra VARCHAR(10) null,
	vlrvenda DECIMAL(6, 4) null,
	vlrcompra DECIMAL(6, 4) null,    
	uncoleta VARCHAR(10),
	bandeira VARCHAR(80),
 PRIMARY KEY (id)
) DEFAULT CHARSET=ucs2 COLLATE=ucs2_unicode_ci;

-- selecionando database que será utilizado
USE aa;

TRUNCATE TABLE AARevendas;

-- script para realizar a importacao do csv
LOAD DATA INFILE  'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\2018-2_CA.csv' 
INTO TABLE AARevendas
CHARACTER SET ucs2
FIELDS TERMINATED BY '\t' 
--  ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(regiao,estado,municipio,revenda,cnpj,cproduto,@datacoleta,@vlrvenda,@vlrcompra,uncoleta,bandeira)
SET
	-- datacoleta = IF( LENGTH(@datacoleta) > 0, DATE_FORMAT(STR_TO_DATE(@datacoleta, '%d/%m/%Y'), '%Y-%m-%d'), NULL),
	vlrvenda = IF( LENGTH(@vlrvenda) > 0, REPLACE(@vlrvenda, ',', '.'), NULL),
    vlrcompra = IF( LENGTH(@vlrcompra) > 0, REPLACE(@vlrcompra, ',', '.'), NULL)
;

SHOW WARNINGS;


USE aa;
SELECT * FROM AARevendas;



-- script para criar as tabelas secundarias e alimentar com os dados da original
use aa;
drop table if exists AAregiao;

CREATE TABLE AAregiao (
	idreg INT NOT NULL AUTO_INCREMENT,
	regiao char(10) NOT NULL,
	estado char(10) NULL,
    municipio char(30) not null,

 PRIMARY KEY (idreg)
) DEFAULT CHARSET=ucs2 COLLATE=ucs2_unicode_ci;

USE aa;
SELECT * FROM AARevendas;

REPLACE INTO AAregiao
	(idreg,
	regiao,
	estado)
SELECT 
	id,
	regiao,
	estado
	
FROM AARevendas;


use aa;

drop table if exists AAproduto;

CREATE TABLE AAproduto
(
	idpro INT NOT NULL AUTO_INCREMENT primary key,
	revenda_id int not null,
    cproduto char(20) not null,
	datacoleta char(20) not null,
	vlrvenda float not null,
    vlrcompra float null,
    uncoleta char(40) not null
 
 
) 
DEFAULT CHARSET=ucs2 COLLATE=ucs2_unicode_ci;


USE aa;
SELECT * FROM AARevendas;

REPLACE INTO AAproduto
	(idpro,
	cproduto,
	datacoleta,
	vlrvenda,
	vlrcompra,
	uncoleta)
SELECT 
	(id,
	cproduto,
	datacoleta,
	vlrvenda,
	vlrcompra,
	uncoleta)
	
FROM AARevendas;

USE aa;

drop table if exists AArevenda;

CREATE TABLE AArevenda
(
	idrev INT NOT NULL AUTO_INCREMENT primary key,
	municipio char(30) not null,
	revenda char(70) not null,
	cnpj int not null,
	cproduto char(20) not null,
	bandeira char(80) not null,
	regiao_id int not null
) 

DEFAULT CHARSET=ucs2 COLLATE=ucs2_unicode_ci;


SELECT * FROM AARevendas;

REPLACE INTO AARevenda
	(idrev,
	municipio,
	revenda,
	cnpj,
	cproduto,
	bandeira)
SELECT 
	(id,
	cproduto,
	datacoleta,
	vlrvenda,
	vlrcompra,
	uncoleta)
	
FROM AARevendas;

alter table AARevenda
  add constraint fk_regiao_revenda foreign key (regiao_id) references AARegiao(idreg);

alter table AAProduto
  add constraint fk_produto_revenda foreign key (revenda_id) references AARevenda(idrev);

drop table AARevendas
