SELECT /*csv*/
  p_mid,
    minf.creditor_bank,
    CASE
            WHEN authentication_type = 'BATCH' THEN (
                SELECT
                    memberifassociate
                FROM
                    membership
                WHERE
                    member_id = minf.debtor_branch_code
                    AND   memberifassociate > 0
                FETCH FIRST ROW ONLY
            )
            ELSE minf.debtor_branch_code
        END
    branch_code,
    minf.debtor_bank,
    minf.creation_date,
    minf.authentication_type,
    minf.contract_reference_number,
    minf.debtor_authentication_required,
    minf.installment_occurence,
    minf.creditor_short_name,
   -- p_msg_sts,
    CASE
            WHEN status = 'NRSP' THEN 'NO_RESPONSE'
            WHEN status = 'NAUT' THEN 'DECLINED'
            WHEN error_code LIKE '9%' THEN 'VALIDATION_FAILURE'
            ELSE status
        END
    status,
    minf.error_code,
    minf.data_source
FROM
    (
        SELECT
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:GrpHdr/b:InstgAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "CREDITOR_BANK",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:GrpHdr/b:InstdAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "DEBTOR_BRANCH_CODE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:GrpHdr/b:InstdAgt/b:FinInstnId/b:ClrSysMmbId/b:MmbId/text()'
,'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "DEBTOR_BANK",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:Mndt/b:Ocrncs/b:Drtn/b:FrDt/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "CREATION_DATE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:Mndt/b:SplmtryData/b:Envlp/b:Cnts/b:AthntctnTp/text()',
'xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "AUTHENTICATION_TYPE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:Mndt/b:MndtReqId/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "CONTRACT_REFERENCE_NUMBER",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:Mndt/b:Tp/b:LclInstrm/b:Prtry/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "DEBTOR_AUTHENTICATION_REQUIRED",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:Mndt/b:Ocrncs/b:SeqTp/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "INSTALLMENT_OCCURENCE",
            extractvalue(xml_msg,'/a:FndtMsg/a:Msg/a:Pmnt/b:Document/b:MndtInitnReq/b:Mndt/b:UltmtCdtr/b:Id/b:OrgId/b:Othr/b:Id/text()','xmlns:a="http://fundtech.com/SCL/CommonTypes" xmlns:b="urn:iso:std:iso:20022:tech:xsd:pain.009.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
) "CREDITOR_SHORT_NAME",
            CASE
                    WHEN p_msg_sts = 'COMPLETE'          THEN 'AUTHENTICATED'
                    WHEN p_msg_sts = 'WAIT_CONFIRMATION' THEN 'RESPONSE_FILE_NOT_RECIEVED'
                    WHEN p_msg_sts = 'TIMEOUT'           THEN 'OUTSTANDING_RESPONSE'
                    WHEN p_msg_sts = 'CANCELED'
                         AND p_previous_msg_sts = 'WAIT_CONFIRMATION' THEN 'OUTSTANDING_RESPONSE'
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
            CASE
                    WHEN p_msg_sts IN (
                        'COMPLETE',
                        'WAIT_CONFIRMATION',
                        'TIMEOUT',
                        'CANCELED'
                    ) THEN ' '
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
            p_mid,
            p_msg_sts
        FROM
            minf
        WHERE
            p_msg_type = 'Pain_009'
            AND   p_cdt_mop = 'BOOK'
            AND   p_dbt_mop IN (
                'AC_MND_TT1',
                'AC_MND_TT2'
            )
            AND   (
                (
                    p_msg_sts IN (
                        'COMPLETE',
                        'REJECTED',
                        'WAIT_CONFIRMATION',
                        'TIMEOUT'
                    )
                    AND   p_previous_msg_sts IN (
                        'WAIT_AUTHORIZATION',
                        'WAIT_CONFIRMATION',
                        '(RECEIVED)'
                    )
                )
                OR    (
                    p_msg_sts = 'CANCELED'
                    AND   p_previous_msg_sts = 'WAIT_CONFIRMATION'
                )
            )
            --AND   p_time_stamp BETWEEN '2018-03-26' AND '2018-04-03'
           
    ) minf 
