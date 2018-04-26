select

EXTRACTVALUE(XML_MSG,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:CstmrPmtCxlReq/b:Assgnmt/b:Assgnr/b:Agt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()',

'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.055.001.04"')"DEBTOR_BANK",

EXTRACTVALUE(XML_MSG,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:CstmrPmtCxlReq/b:Undrlyg/b:OrgnlPmtInfAndCxl/b:TxInf/b:OrgnlTxRef/b:CdtrAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()',

'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.055.001.04"')"CREDITOR_BANK",

EXTRACTVALUE(XML_MSG,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:CstmrPmtCxlReq/b:Assgnmt/b:CreDtTm/text()',

'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.055.001.04"')"CREATION_DATE",

EXTRACTVALUE(XML_MSG,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:CstmrPmtCxlReq/b:Undrlyg/b:OrgnlPmtInfAndCxl/b:TxInf/b:CxlRsnInf/b:Rsn/b:Prtry/text()',

'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.055.001.04"')"REASON_CODE",

CASE

WHEN P_MSG_STS = 'COMPLETE' THEN 'SUCCESSFUL MANDATE SUSPENDED'

ELSE 'REJECTED' END "STATUS",

'BANK' AS "DATA_SOURCE",

P_MID

from gpp_sp.MINF

where P_MSG_TYPE = 'Camt_055'

and P_MSG_STS IN ('COMPLETE','REJECTED')

and P_CDT_MOP = 'AC_MND_TT2'

and P_DBT_MOP = 'BOOK'

and P_TIME_STAMP BETWEEN '2018-03-01' and '2018-04-25'