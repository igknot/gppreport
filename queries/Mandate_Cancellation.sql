SELECT 
 --* 
    --MINF.p_mid,
    minf.creditor_bank,
    --
    membership.memberifassociate debtor_bank,
    substr(minf.creation_date,1,10) creation_date,
    minf.authentication_type,
    minf.cancellation_reason,
    minf.creditor_short_name,
    minf.status, 
    gpp_sp.msgerr.EXT_ERROR_CODE ERROR_CODE, 
 --MINF.ERROR_CODE , 
    minf.data_source
FROM
    (
        SELECT
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtCxlReq/b:GrpHdr/b:InstgAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.011.001.03"') "CREDITOR_BANK",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtCxlReq/b:GrpHdr/b:InstdAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.011.001.03"') "DEBTOR_BANK",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtCxlReq/b:GrpHdr/b:CreDtTm/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.011.001.03"'
) "CREATION_DATE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtCxlReq/b:UndrlygCxlDtls/b:SplmtryData/b:Envlp/b:Cnts/b:AthntctnTp/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.011.001.03"') "AUTHENTICATION_TYPE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtCxlReq/b:UndrlygCxlDtls/b:CxlRsn/b:Rsn/b:Prtry/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.011.001.03"'
) "CANCELLATION_REASON",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtCxlReq/b:UndrlygCxlDtls/b:OrgnlMndt/b:OrgnlMndt/b:UltmtCdtr/b:Id/b:OrgId/b:Othr/b:Id/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.011.001.03"') "CREDITOR_SHORT_NAME",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtCxlReq/b:UndrlygCxlDtls/b:OrgnlMndt/b:OrgnlMndt/b:MndtReqId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.011.001.03"') "CONTRACT_REFERENCE_NUMBER"
,
            CASE
                    WHEN p_msg_sts = 'COMPLETE' THEN 'SUCESSFUL'
                    ELSE 'REJECTED'
                END
            "STATUS",
            'BANK' AS "DATA_SOURCE",
            p_mid ,
            p_time_stamp
        FROM
            gpp_sp.minf
        WHERE
            p_msg_type = 'Pain_011'
            AND   p_msg_sts IN (
                'COMPLETE',
                'REJECTED',
                'TIMEOUT'
            )
            AND   p_previous_msg_sts IN (
                'WAIT_AUTHORIZATION',
                'WAIT_CONFIRMATION'
            )
            AND   p_cdt_mop = 'BOOK'
            AND   p_dbt_mop IN (
                'AC_MND_TT1',
                'AC_MND_TT2'
            )
    --AND   p_time_stamp BETWEEN '2018-03-26' AND '2018-04-18';
    ) minf
    JOIN gppsp.membership ON membership.member_id = minf.debtor_bank
    JOIN gpp_sp.msgerr ON msgerr.mid = minf.p_mid
WHERE
    memberifassociate > 0
