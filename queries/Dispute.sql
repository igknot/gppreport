select 
 --minf.p_mid ,
 minf.debtor_bank ,
 membership.memberifassociate creditor_bank,            
 substr (minf.creation_date,1,10) CREATION_DATE ,
 minf.reason_code,
 
   
   minf.status,
   
   minf.error_code,
   minf.data_source

from 
(SELECT
    p_mid ,
    '210001' debtor_bank,
    extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:PmtRtr/b:TxInf/b:OrgnlTxRef/b:DbtrAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
            ,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.004.001.03" ') 
            creditor_branch_code,
     extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:PmtRtr/b:GrpHdr/b:CreDtTm/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.004.001.03" '
            ) 
            creation_date,
    extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:PmtRtr/b:TxInf/b:RtrRsnInf/b:Rsn/b:Prtry/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.004.001.03" '
            ) 
            reason_code,
                CASE
                    WHEN p_msg_sts = 'COMPLETE' THEN 'SUCESSFUL'
                    WHEN p_msg_sts = 'REJECTED' THEN 'VALIDATION_FAILURE'
                    WHEN p_msg_sts = 'MP_WAIT' THEN 'OUTSTANDING_RESPONSE'
                    ELSE p_msg_sts
                END
            status,
            
            p_msg_sts ,
            '' error_code,
            'BANK' data_source,
            p_time_stamp

FROM
    minf
WHERE
    p_msg_type = 'Pacs_004'
    AND   p_cdt_mop = 'BOOK'
    AND   p_dbt_mop = 'AC' ) MINF 
    JOIN GPPSP.membership ON membership.member_id = minf.creditor_branch_code
WHERE
    memberifassociate > 0
    --AND   p_time_stamp > ( '2018-03-23' )
--FETCH FIRST 10 ROWS ONLY

