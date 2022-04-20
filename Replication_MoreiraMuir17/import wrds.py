import wrds
import psycopg2
conn = psycopg2.connect(dbname='wrds', 
                        user='Ygungor', 
                        host='wrds-pgdata.wharton.upenn.edu', 
                        port=9737) 
from dateutil.relativedelta import *


# connect with their server
conn=wrds.Connection()
wrds_username='Ygungor')

# get the value-weighted market returns and date from the data base crsp.dsi
mkt_d = conn.raw_sql("""
                      select a.date, a.vwretd
                      from crsp.dsi as a
                      """) 
# get the risk-free rate
rf_d = conn.raw_sql("""
                      select a.date, a.rf
                      from ff.factors_daily as a
                      """)

mkt_d=mkt_d.set_index(['date'])

mkt_d=mkt_d.set_index(pd.to_datetime(mkt_d.index),'date')

rf_d=rf_d.set_index(['date'])

rf_d=rf_d.set_index(pd.to_datetime(rf_d.index),'date')

# we merge

daily=mkt_d.merge(rf_d,how='left',left_index=True,right_index=True)
# save data locally
#daily.to_pickle('../../assets/data/daily.pkl')