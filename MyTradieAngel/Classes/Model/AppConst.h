//
//  AppConst.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 1/2/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height > 480 ? TRUE : FALSE
#define API_BASE_URL @"http://www.tradieangel.com.au/api/"

// -------- Define app constant variables
static const int MAXROWS = 15;

static const int debugBaseVC = 1;
static const int debugModel = 1;
static const int debugUtils = 1;
static const int debugDatabase = 1;

static const int debugLoginPageVC = 1;
static const int debugSignupPageVC = 1;
static const int debugHomePageVC = 1;
static const int debugSettingsMenuVC = 1;
static const int debugCompanyInfoPageVC = 1;
static const int debugChagnePswdPageVC = 1;

static const int debugInvoicesPageVC = 1;
static const int debugInvoicePageVC = 1;

static const int debugQuotesPageVC = 1;
static const int debugQuotePageVC = 1;

static const int debugPaymentsPageVC = 1;
static const int debugPaymentPageVC = 1;

static const int debugCustomersPageVC = 1;
static const int debugCustomerPageVC = 1;

static const int debugAppsPageVC = 1;
static const int debugAppPageVC = 1;
static const int debugRecurAppsPageVC = 1;

static const int debugMoneyMenuVC = 1;
static const int debugBCostsPageVC = 1;
static const int debugBCostPageVC = 1;
static const int debugMoneyPageVC = 1;

static const int debugHeadsPageVC = 1;

static const int debugPdfPageVC = 1;


static const int LOGOUT = 0;
static const int LOGIN = 1;
static const int SIGNUP = 2;
static const int CHANGE_PSWD = 3;
static const int GET_USER_SETTINGS = 4;
static const int UPDATE_SETTINGS = 5;
static const int REFRESH_DATA = 6;
static const int SYNC_DATA = 7;

static const int GET_INVOICE_LIST = 10;
static const int GET_INVOICE_DETAILS = 11;
static const int DEL_INVOICE = 12;
static const int GET_LATEST_INVOICE_ID = 13;
static const int GET_CUSTOMERS_LOOKUP = 14;
static const int UPDATE_INVOICE = 15;
static const int GET_INVOICE_PDF = 16;

static const int GET_QUOTE_LIST = 20;
static const int GET_QUOTE_DETAILS = 21;
static const int DEL_QUOTE = 22;
static const int GET_LATEST_QUOTE_ID = 23;
static const int UPDATE_QUOTE = 24;
static const int GET_QUOTE_PDF = 25;

static const int GET_PAYMENT_LIST = 30;
static const int GET_PAYMENT_DETAILS = 31;
static const int DEL_PAYMENT = 32;
static const int MAKE_PAYMENT = 33;

static const int GET_CUSTOMER_LIST = 40;
static const int DEL_CUSTOMER = 41;
static const int GET_CUSTOMER_DETAILS = 42;
static const int UPDATE_CUSTOMER = 43;

static const int GET_APPS_LIST = 50;
static const int GET_APP_DETAILS = 51;
static const int NEW_APP = 52;
static const int ADD_APP = 53;
static const int DEL_APP = 54;

static const int GET_RECUR_APPS_LIST = 60;
static const int DEL_RECUR_APP = 61;

static const int GET_COST_LIST = 70;
static const int GET_COST_DETAILS = 71;
static const int DEL_COST = 72;
static const int UPDATE_COST = 73;

static const int GET_HEAD_LIST = 80;
static const int DEL_HEAD = 81;
static const int UPDATE_HEAD = 82;

static const int EDIT_BTN = 0;
static const int DEL_BTN = 1;
static const int MONEY_BTN = 2;
static const int FILE_BTN = 3;
static const int MAIL_BTN = 4;



