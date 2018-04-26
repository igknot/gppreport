SELECT
    minf.p_mid,
    minf.debtor_bank,
    minf.creditor_bank,
    substr (minf.creation_date,1,10) CREATION_DATE ,
    minf.reason_code,
    minf.status,
    (
        SELECT
            extractvalue(minf_inner.xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:RsltnOfInvstgtn/b:Sts/b:Conf/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.029.001.04"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
)
        FROM
            gppsp.mfamily
            JOIN gppsp.minf minf_inner ON mfamily.related_mid = minf_inner.p_mid
        WHERE
            minf.p_mid = mfamily.p_mid
            AND   mfamily.related_type = 'Answer'
        ORDER BY
            time_stamp DESC
        FETCH FIRST ROW ONLY
    ) status_of_investigation,
    minf.error_code,
    minf.data_source
FROM
    (
        SELECT
            p_mid,
            ---
           
            ---
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFIPmtCxlReq/b:Undrlyg/b:TxInf/b:Assgnr/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'            
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.056.001.02" ') debtor_bank,

            '210001' creditor_bank,
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFIPmtCxlReq/b:Assgnmt/b:CreDtTm/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.056.001.02" '
) creation_date,
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFIPmtCxlReq/b:Undrlyg/b:TxInf/b:CxlRsnInf/b:Rsn/b:Prtry/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:camt.056.001.02" '
) reason_code,
            CASE
                    WHEN p_msg_sts = 'SERVICE_COMPLETE' THEN 'SUCESSFUL'
                    WHEN p_msg_sts = 'SERVICE_REJECTED' THEN 'VALIDATION_FAILURE'
                    ELSE 'STATUS_UNKNOWN'
                END
            status,
            ' ' error_code,
            'BANK' data_source
        FROM
            minf
        WHERE
            p_msg_type = 'Camt_056'
            AND   p_cdt_mop = 'BOOK'
            AND   p_dbt_mop = 'AC'
    --AND   p_time_stamp > ( '2018-03-23' )
    ) minf
     