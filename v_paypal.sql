DROP VIEW  v_paypal;
CREATE VIEW v_paypal 
AS
SELECT Activity, ROUND(Debit,2) AS Debit, Round(Credit,2) AS Credit, Status, Currency, Round(QBO_Activity,2) AS QBO_Activity, srt
FROM (
SELECT 'Sales activity' AS Activity, '-' AS Debit, SUM(Gross) AS Credit, Status, Currency, '' AS QBO_Activity, 1 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Tax collected by partner', 'eBay Auction Payment', 'Express Checkout Payment', 'General Payment',  'Mobile Payment')
   AND BalanceImpact = 'Credit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT 'Sales activity - PayPal Income' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(Gross - ShippingandHandlingAmount - InsuranceAmount - SalesTax),2) AS QBO_Activity, 2 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Tax collected by partner', 'eBay Auction Payment', 'Express Checkout Payment', 'General Payment',  'Mobile Payment')
   AND BalanceImpact = 'Credit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT 'Sales activity - PayPal Income SalesTax' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(SalesTax),2) AS QBO_Activity, 3 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Tax collected by partner', 'eBay Auction Payment', 'Express Checkout Payment', 'General Payment',  'Mobile Payment')
   AND BalanceImpact = 'Credit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT 'Sales activity - PayPal Income ShippingandHandlingAmount' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(ShippingandHandlingAmount),2) AS QBO_Activity, 4 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Tax collected by partner', 'eBay Auction Payment', 'Express Checkout Payment', 'General Payment',  'Mobile Payment')
   AND BalanceImpact = 'Credit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT 'Sales activity - PayPal Income InsuranceAmount' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(InsuranceAmount),2) AS QBO_Activity, 5 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Tax collected by partner', 'eBay Auction Payment', 'Express Checkout Payment', 'General Payment',  'Mobile Payment')
   AND BalanceImpact = 'Credit'
 GROUP BY Status, Currency
 UNION ALL 
SELECT 'Refunds sent' AS Activity,SUM(Gross) AS Debit, '-' AS Credit, Status, Currency, '' AS QBO_Activity, 6 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Payment Refund')
   AND BalanceImpact = 'Debit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT  'Refunds sent - PayPal Income' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, -1 * ROUND(SUM(ABS(Gross) - ABS(ShippingandHandlingAmount) - ABS(InsuranceAmount) - ABS(SalesTax)),2) AS QBO_Activity, 7 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Payment Refund')
   AND BalanceImpact = 'Debit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT  'Refunds sent - PayPal SalesTax' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, -1 * ROUND(SUM(SalesTax),2) AS QBO_Activity, 8 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Payment Refund')
   AND BalanceImpact = 'Debit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT  'Refunds sent - PayPal ShippingandHandlingAmount' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, -1 * ROUND(SUM(ShippingandHandlingAmount),2) AS QBO_Activity, 9 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Payment Refund')
   AND BalanceImpact = 'Debit'
 GROUP BY Status, Currency
 UNION ALL 
 SELECT  'Refunds sent - PayPal InsuranceAmount' AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, -1 * ROUND(SUM(InsuranceAmount),2) AS QBO_Activity, 10 AS srt
FROM PAYPAL_TRANS
WHERE Type IN ('Payment Refund')
   AND BalanceImpact = 'Debit'
 GROUP BY Status, Currency
  UNION ALL 
SELECT 'eBay Auction Fees' AS Activity, ROUND(SUM(Fee),2) AS Debit, '-' AS Credit, Status, Currency , ROUND(SUM(Fee),2)  AS QBO_Activity, 11 AS srt
FROM PAYPAL_TRANS
WHERE  BalanceImpact = 'Credit'
GROUP BY  Status, Currency 
  UNION ALL 
SELECT 'Chargeback fees' AS Activity, ROUND(SUM(Gross),2) AS Debit, '-' AS Credit, Status, Currency , ROUND(SUM(Gross),2) AS QBO_Activity, 12 AS srt
FROM PAYPAL_TRANS
WHERE type LIKE 'Chargeback Fee%'  
  AND BalanceImpact = 'Debit'
GROUP BY  Status, Currency
  UNION ALL 
SELECT 'Chargeback & disputes' AS Activity, ROUND(SUM(Gross),2) AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity, 13 AS srt
FROM PAYPAL_TRANS
WHERE type = 'Chargeback'  
  AND BalanceImpact = 'Debit'
GROUP BY  Status, Currency
   UNION ALL 
SELECT 'Currency transfers' AS Activity, ROUND(SUM(CASE WHEN BalanceImpact = 'Debit' THEN Gross END),2) AS Debit, ROUND(SUM(CASE WHEN BalanceImpact = 'Credit' THEN Gross END),2) AS Credit, Status, Currency, ROUND(SUM(Gross),2)  AS QBO_Activity, 14 AS srt
FROM PAYPAL_TRANS
WHERE type = 'General Currency Conversion'
 GROUP BY  Status, Currency
    UNION ALL 
SELECT 'Transfer to Paypal account' AS Activity, '-' AS Debit, ROUND(SUM(Gross),2) AS Credit, Status, Currency, '' AS QBO_Activity, 15 AS srt
FROM PAYPAL_TRANS
WHERE ( type LIKE 'Bank Deposit to PP Account%'
    OR type = 'General Credit Card Deposit')
  AND BalanceImpact = 'Credit'
 GROUP BY  Status, Currency
   UNION ALL 
SELECT 'Transfer to Paypal account - '  || Date || '-' || TransactionID AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity, 16 AS srt
FROM PAYPAL_TRANS
WHERE type LIKE 'Bank Deposit to PP Account%'
  AND BalanceImpact = 'Credit'
 GROUP BY  Status, Currency, Activity
     UNION ALL 
SELECT 'Transfer from Paypal account' AS Activity, ROUND(SUM(Gross),2) AS Debit, '-' AS Credit, Status, Currency, '' AS QBO_Activity, 17 AS srt
FROM PAYPAL_TRANS
WHERE type =  'General Withdrawal'
  AND BalanceImpact = 'Debit'
 GROUP BY  Status, Currency
UNION ALL
SELECT 'Transfer from Paypal account - '  || Date || '-' || TransactionID AS Activity, '' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity, 18 AS srt
FROM PAYPAL_TRANS
WHERE type =  'General Withdrawal'
  AND BalanceImpact = 'Debit'
 GROUP BY  Status, Currency, Activity
      UNION ALL 
SELECT 'Online payments sent' AS Activity, ROUND(SUM(Gross),2) AS Debit, '-' AS Credit, Status, Currency, '' AS QBO_Activity, 19 AS srt
FROM PAYPAL_TRANS
WHERE  type IN ('Tax collected by partner', 'eBay Auction Payment', 'Express Checkout Payment', 'General Payment', 'PreApproved Payment Bill User Payment', 'Postage Payment', 'Website Payment', 'Subscription Payment')
  AND BalanceImpact = 'Debit'
 GROUP BY  Status, Currency
       UNION ALL 
SELECT  'Online payments sent - '  ||  
                  CASE 
				      WHEN Name = 'eBay Inc Shipping' THEN 'eBay Inc Shipping' 
				      WHEN ToEmailAddress LIKE '%ebay-fees%' THEN 'eBay Express Checkout Fees' 
				      WHEN Type = 'Tax collected by partner' THEN 'Tax collected by partner'
				      WHEN Note LIKE 'This is for reimbursement of postage from your sale to Sell My Comic Books.%' THEN ' Reimbursement for Postage' ELSE Type ||  '-'|| Name  ||  '-' || TransactionID  END AS Name2, '-' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity , 20 AS srt 
FROM PAYPAL_TRANS
WHERE  type IN ('Tax collected by partner', 'eBay Auction Payment', 'Express Checkout Payment', 'General Payment', 'PreApproved Payment Bill User Payment', 'Postage Payment', 'Website Payment', 'Subscription Payment')
  AND BalanceImpact = 'Debit'
 GROUP BY  Status, Currency, Name2
       UNION ALL 
SELECT 'Refunds received' AS Activity, '-' AS Debit, ROUND(SUM(Gross),2) AS Credit, Status, Currency, ROUND(SUM(Gross),2)  AS QBO_Activity, 22 AS srt
FROM PAYPAL_TRANS
WHERE  type = 'Payment Refund'
  AND BalanceImpact = 'Credit'
 GROUP BY  Status, Currency
        UNION ALL 
SELECT 'Refunds received from-' || FromEmailAddress || '-' || TransactionID AS Activity, '-' AS Debit, ROUND(SUM(Gross),2) AS Credit, Status, Currency, ROUND(SUM(Gross),2)  AS QBO_Activity, 22 AS srt
FROM PAYPAL_TRANS
WHERE  type = 'Payment Refund'
  AND BalanceImpact = 'Credit'
 GROUP BY  Activity, Status, Currency
        UNION ALL 
SELECT 'Debit card purchases' AS Activity, ROUND(SUM(Gross),2) AS Debit, '-' AS Credit, Status, Currency, '' AS QBO_Activity, 23 AS srt
FROM PAYPAL_TRANS
WHERE  type = 'General PayPal Debit Card Transaction'
  AND BalanceImpact = 'Debit'
 GROUP BY  Status, Currency
         UNION ALL 
SELECT 'Debit card purchases - ' || Name AS Activity, '-' AS Debit, '-' AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity, 24 AS srt
FROM PAYPAL_TRANS
WHERE  type = 'General PayPal Debit Card Transaction'
  AND BalanceImpact = 'Debit'
 GROUP BY  Name, Status, Currency
         UNION ALL 
SELECT 'Debit card returns' AS Activity, '-' AS Debit, ROUND(SUM(Gross),2) AS Credit, Status, Currency, '' AS QBO_Activity, 25 AS srt
FROM PAYPAL_TRANS
WHERE  type = 'General PayPal Debit Card Transaction'
  AND BalanceImpact = 'Credit'
 GROUP BY  Status, Currency
 UNION ALL
SELECT 'Debit card returns - ' || Name AS Activity, '-' AS Debit, '' AS Credit, Status, Currency, ROUND(SUM(Gross),2)  AS QBO_Activity, 26 AS srt
FROM PAYPAL_TRANS
WHERE  type = 'General PayPal Debit Card Transaction'
  AND BalanceImpact = 'Credit'
 GROUP BY  Status, Currency
          UNION ALL 
SELECT 'Debit card cashback' AS Activity, '-' AS Debit, ROUND(SUM(Gross),2)  AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity, 27 AS srt
FROM PAYPAL_TRANS
WHERE  type = 'Debit Card Cash Back Bonus'
  AND BalanceImpact = 'Credit'
 GROUP BY  Status, Currency
          UNION ALL 
SELECT 'Other' AS Activity, ROUND(SUM(CASE WHEN BalanceImpact = 'Debit' THEN Gross ELSE 0 END),2) AS Debit, ROUND(SUM(CASE WHEN BalanceImpact = 'Credit' THEN Gross ELSE 0 END),2)  AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity, 28 AS srt
FROM PAYPAL_TRANS
WHERE  type IN ( 'Account Hold for Open Authorization', 'Reversal of General Account Hold')
 GROUP BY  Status, Currency
           UNION ALL 
SELECT 'Chargebacks & disputes' AS Activity, ROUND(SUM(CASE WHEN BalanceImpact = 'Debit' THEN Gross ELSE 0 END),2) AS Debit, ROUND(SUM(CASE WHEN BalanceImpact = 'Credit' THEN Gross ELSE 0 END),2)  AS Credit, Status, Currency, ROUND(SUM(Gross),2) AS QBO_Activity, 10 AS srt
FROM PAYPAL_TRANS
WHERE  type IN ( 'Instant Payment Review (IPR) reversal')
 GROUP BY  Status, Currency) x;
