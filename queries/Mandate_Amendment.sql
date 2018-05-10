SELECT --* 
    
    --minf.p_mid,
    minf.creditor_bank,
    --minf.debtor_bank,
    CASE
            WHEN authentication_type = 'BATCH' THEN (
                SELECT
                    memberifassociate
                FROM
                    membership
                WHERE
                    member_id = minf.branch_code
                    AND   memberifassociate > 0
                FETCH FIRST ROW ONLY
            )
            ELSE minf.branch_code
        END
    debtor_bank,
    minf.creation_date,
    minf.amendment_reason,
    minf.authentication_type,
    minf.contract_reference_number,
    minf.debtor_authentication_required,
    minf.installment_occurence,
    minf.creditor_short_name,
    minf.p_msg_sts ,
    --minf.status,
    CASE 
        WHEN  minf.debtor_authentication_required = '0226' THEN 'NOTIFICATION'
        WHEN MINF.STATUS = 'NRSP' THEN 'NO_RESPONSE'
        WHEN MINF.STATUS = 'NAUT' THEN 'DECLINED'
        WHEN minf.p_msg_sts ='REJECTED' and minf.STATUS is null  and error_code LIKE '9%' THEN 'VALIDATION_FAILURE'
        ELSE MINF.STATUS
    END STATUS , 
    minf.error_code,
    minf.data_source
FROM
    (
        SELECT
          
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:GrpHdr/b:InstgAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"') "CREDITOR_BANK",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:GrpHdr/b:InstdAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"') "DEBTOR_BANK",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:GrpHdr/b:InstdAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) branch_code,
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:GrpHdr/b:CreDtTm/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"'
) "CREATION_DATE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:UndrlygAmdmntDtls/b:AmdmntRsn/b:Rsn/b:Prtry/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"'
) "AMENDMENT_REASON",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:UndrlygAmdmntDtls/b:SplmtryData/b:Envlp/b:Cnts/b:AthntctnTp/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"') "AUTHENTICATION_TYPE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:UndrlygAmdmntDtls/b:Mndt/b:MndtId/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"'
) "CONTRACT_REFERENCE_NUMBER",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:UndrlygAmdmntDtls/b:Mndt/b:Tp/b:LclInstrm/b:Prtry/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"') "DEBTOR_AUTHENTICATION_REQUIRED"
,
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:UndrlygAmdmntDtls/b:Mndt/b:Ocrncs/b:SeqTp/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"'
) "INSTALLMENT_OCCURENCE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAmdmntReq/b:UndrlygAmdmntDtls/b:Mndt/b:UltmtCdtr/b:Id/b:OrgId/b:Othr/b:Id/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.010.001.03"') "CREDITOR_SHORT_NAME",
            CASE
                    WHEN p_msg_sts = 'COMPLETE' THEN 'AUTHENTICATED'
                    ELSE (
                        SELECT
                            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtAccptncRpt/b:UndrlygAccptncDtls/b:OrgnlMndt/b:OrgnlMndt/b:RfrdDoc/b:Tp/b:CdOrPrtry/b:Prtry/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.012.001.03"')
                        FROM
                            mfamily
                            JOIN minf minf_inner ON mfamily.related_mid = minf_inner.p_mid
                        WHERE
                            minf.p_mid = mfamily.p_mid
                        ORDER BY
                            time_stamp DESC
                        FETCH FIRST ROW ONLY
                    )
                END
            "STATUS",
            p_msg_sts ,
            
            CASE
                    WHEN p_msg_sts = 'COMPLETE' THEN ' '
                    ELSE (
                        SELECT
                            ext_error_code
                        FROM
                            msgerr
                        WHERE
                            minf.p_mid = msgerr.mid
                        FETCH FIRST ROW ONLY
                    )
                END
            "ERROR_CODE",
            'BANK' AS "DATA_SOURCE",
            p_mid ,
            p_time_stamp
        FROM
            gpp_sp.minf
        WHERE
            p_msg_type = 'Pain_010'
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

--and P_TIME_STAMP BETWEEN '2018-03-26' and '2018-04-18' 
    ) minf WHERE 1 =1


