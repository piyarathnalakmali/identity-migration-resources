UPDATE SP_APP 
SET 
	APP_NAME = 'My Account', 
	IS_SAAS_APP = 1,
	DESCRIPTION = 'This is the my account application.'
WHERE 
	 ID = (SELECT APP_ID FROM SP_INBOUND_AUTH WHERE INBOUND_AUTH_KEY = 'USER_PORTAL' AND TENANT_ID = -1234);

 
DECLARE @COMMAND NVARCHAR(200);SELECT TOP 1 @COMMAND= 'ALTER TABLE IDN_OIDC_PROPERTY DROP CONSTRAINT ' + RC.CONSTRAINT_NAME + ';' 
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF 
ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP 
ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME WHERE KF.TABLE_NAME = 'IDN_OIDC_PROPERTY' AND KP.TABLE_NAME='IDN_OAUTH_CONSUMER_APPS';EXEC (@COMMAND);

UPDATE IDN_OAUTH_CONSUMER_APPS
SET 
	CONSUMER_KEY = 'MY_ACCOUNT', 
	CALLBACK_URL = REPLACE(CALLBACK_URL, 'user-portal/login', 'myaccount/login'),
	APP_NAME = 'My Account' 
WHERE 
	CONSUMER_KEY = 'USER_PORTAL' AND TENANT_ID = -1234;
	
UPDATE IDN_OIDC_PROPERTY 
SET 
	CONSUMER_KEY = 'MY_ACCOUNT'
WHERE 
	CONSUMER_KEY = 'USER_PORTAL' AND TENANT_ID = -1234;	
	

ALTER TABLE IDN_OIDC_PROPERTY
ADD FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE;


DELETE FROM IDN_OIDC_PROPERTY WHERE TENANT_ID = -1234 AND CONSUMER_KEY = 'MY_ACCOUNT' AND PROPERTY_KEY = 'tokenRevocationWithIDPSessionTermination';
DELETE FROM IDN_OIDC_PROPERTY WHERE TENANT_ID = -1234 AND CONSUMER_KEY = 'MY_ACCOUNT' AND PROPERTY_KEY = 'tokenBindingValidation';
DELETE FROM IDN_OIDC_PROPERTY WHERE TENANT_ID = -1234 AND CONSUMER_KEY = 'MY_ACCOUNT' AND PROPERTY_KEY = 'tokenBindingType';

INSERT INTO IDN_OIDC_PROPERTY (TENANT_ID, CONSUMER_KEY, PROPERTY_KEY, PROPERTY_VALUE) 
SELECT -1234, 'MY_ACCOUNT', 'tokenRevocationWithIDPSessionTermination', 'true'
WHERE EXISTS (SELECT * FROM IDN_OAUTH_CONSUMER_APPS WHERE IDN_OAUTH_CONSUMER_APPS.CONSUMER_KEY = 'MY_ACCOUNT');

INSERT INTO IDN_OIDC_PROPERTY (TENANT_ID, CONSUMER_KEY, PROPERTY_KEY, PROPERTY_VALUE) 
SELECT -1234, 'MY_ACCOUNT', 'tokenBindingValidation', 'true'
WHERE EXISTS (SELECT * FROM IDN_OAUTH_CONSUMER_APPS WHERE IDN_OAUTH_CONSUMER_APPS.CONSUMER_KEY = 'MY_ACCOUNT');

INSERT INTO IDN_OIDC_PROPERTY (TENANT_ID, CONSUMER_KEY, PROPERTY_KEY, PROPERTY_VALUE) 
SELECT -1234, 'MY_ACCOUNT', 'tokenBindingType', 'sso-session'
WHERE EXISTS (SELECT * FROM IDN_OAUTH_CONSUMER_APPS WHERE IDN_OAUTH_CONSUMER_APPS.CONSUMER_KEY = 'MY_ACCOUNT');


UPDATE SP_INBOUND_AUTH
SET
	INBOUND_AUTH_KEY = 'MY_ACCOUNT'
WHERE 
	INBOUND_AUTH_KEY = 'USER_PORTAL' AND TENANT_ID = -1234;

DELETE FROM SP_APP WHERE APP_NAME = 'User Portal'AND TENANT_ID <> -1234;
DELETE FROM SP_INBOUND_AUTH WHERE INBOUND_AUTH_KEY = 'User Portal' AND TENANT_ID = -1234;
DELETE FROM IDN_OAUTH_CONSUMER_APPS WHERE CONSUMER_KEY LIKE 'USER_PORTAL%.com' AND TENANT_ID <> -1234;
