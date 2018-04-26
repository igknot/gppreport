SELECT
    --minf.p_mid,
    minf.creditor_bank,
    membership.memberifassociate debtor_bank,
    action_date,
    tracking_period,
    debit_sequence_type,
    entry_class,
    creditor_short_name,
    sts STATUS,
    CASE
            WHEN status = 'REJECTED' THEN (
            
            ----------------
                SELECT
                    extractvalue(minf_inner.xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFIPmtStsRpt/b:TxInfAndSts/b:StsRsnInf/b:Rsn/b:Prtry/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.002.001.04"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "ERROR_CODE"
                FROM
                  GPPSP.mfamily
                    JOIN GPPSP.minf minf_inner ON mfamily.related_mid = minf_inner.p_mid
                WHERE
                    minf.p_mid = mfamily.p_mid
                    AND   mfamily.related_type = 'Incoming Reject Return'
                ORDER BY
                    time_stamp DESC
                FETCH FIRST ROW ONLY
            )-----------------
            ELSE ' '
        END
    error_code,
    --Errror_code , 
    'BANK' data_source
FROM
    (
        SELECT
            p_msg_type,
            '210001' "CREDITOR_BANK",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFICstmrDrctDbt/b:DrctDbtTxInf/b:DbtrAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.03"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "DEBTOR_BRANCH_CODE",
            p_dbtr_agt_bic_2and,
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFICstmrDrctDbt/b:DrctDbtTxInf/b:IntrBkSttlmDt/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.03"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "ACTION_DATE",
            p_orig_sttlm_dt,
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFICstmrDrctDbt/b:DrctDbtTxInf/b:PmtTpInf/b:LclInstrm/b:Prtry/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.03"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "TRACKING_PERIOD",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFICstmrDrctDbt/b:DrctDbtTxInf/b:PmtTpInf/b:SeqTp/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.03"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "DEBIT_SEQUENCE_TYPE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFICstmrDrctDbt/b:DrctDbtTxInf/b:PmtTpInf/b:CtgyPurp/b:Prtry/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.03"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "ENTRY_CLASS",
            substr(extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:FIToFICstmrDrctDbt/b:DrctDbtTxInf/b:RmtInf/b:Ustrd/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes"  xmlns:b="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.03"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
),1,10) "CREDITOR_SHORT_NAME",
            p_msg_sts AS "STATUS",
            p_mid,
            CASE
                    WHEN p_msg_sts = 'COMPLETE'                 THEN 'SUCESSFUL'
                    WHEN p_msg_sts = 'REJECTED'                 THEN 'UNSUCESSFUL'
                    WHEN p_msg_sts = 'WAIT_CONFIRMATION'        THEN 'OUTSTANDING_RESPONSE'
                    WHEN p_msg_sts = 'PENDING_DBT_CONFIRMATION' THEN 'RESPONSE_FILE_NOT_RECIEVED'
                    WHEN p_msg_sts = 'RETURNED'                 THEN 'DISPUTED'
                    ELSE 'STATUS_UNKNOWN'
                END
            "STS" ,
          p_time_stamp

        FROM
          GPPSP.minf
        WHERE
            p_msg_type = 'Pacs_003'
            AND   p_cdt_mop = 'BOOK'
            AND   p_dbt_mop = 'AC'
            --AND   p_time_stamp > ( '2018-03-23' )
    ) minf
    JOIN GPPSP.membership ON membership.member_id = minf.debtor_branch_code
WHERE
    memberifassociate > 0
