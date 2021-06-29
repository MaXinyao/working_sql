import sys
import datetime
import dateutil
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from google.cloud import bigquery
from google_auth_oauthlib import flow
from google.oauth2.service_account import Credentials
import pandas_gbq as gbp
import json
import scipy.stats as stats
import scipy.optimize as opt
from sklearn.ensemble import RandomForestRegressor
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import PolynomialFeatures
from sklearn import linear_model
import scipy as sp
from scipy.stats import norm
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score,precision_score,recall_score,f1_score
from sklearn.metrics import auc,roc_auc_score,roc_curve,precision_recall_curve
from sklearn.model_selection import learning_curve
from scipy.sparse import hstack
from sklearn.metrics import classification_report
from sklearn.model_selection import GridSearchCV
from math import log
from sklearn.metrics import confusion_matrix, mean_squared_error
from sklearn.model_selection import ShuffleSplit
from sklearn import preprocessing
from sklearn.linear_model import LinearRegression


class LtvPredictModel(object):

    def __init__(self, production_id, features, train_start, train_end, test_start, test_end, train_days, minimum_campaign_size):
        self.production_id = production_id
        self.features = features
        self.train_start = train_start
        self.train_end = train_end
        self.test_start = test_start
        self.test_end = test_end
        self.train_days = train_days
        self.minimum_campaign_size = minimum_campaign_size
    
    def run_query(self, query):
        production_id = self.production_id
        client = Client(production_id)
        query = get_query()
        df = client.query(query).to_dataframe()
        return df

    def get_query(self):
        base_sql_part1 = '''
            SELECT 
                fea_x.create_date
                ,fea_x.first_country
                ,fea_x.campaign_name
                ,fea_x.newusers
                ,fea_x.ua_cost
                ,CASE WHEN fea_x.newusers > 0 THEN fea_x.r1users/fea_x.newusers ELSE 0 END AS retention1
                ,CASE WHEN fea_x.newusers > 0 THEN fea_x.r2users/fea_x.newusers ELSE 0 END AS retention2
                ,CASE WHEN fea_x.newusers > 0 THEN fea_x.r3users/fea_x.newusers ELSE 0 END AS retention3
                ,CASE WHEN fea_x.newusers > 0 THEN fea_x.rev0/fea_x.newusers ELSE 0 END AS arpu0
                ,CASE WHEN fea_x.r1users > 0 THEN fea_x.rev1/fea_x.r1users ELSE 0 END AS arpu1
                ,CASE WHEN fea_x.r2users > 0 THEN fea_x.rev2/fea_x.r2users ELSE 0 END AS arpu2
                ,CASE WHEN fea_x.r3users > 0 THEN fea_x.rev3/fea_x.r3users ELSE 0 END AS arpu3
                ,CASE WHEN fea_x.newusers > 0 THEN fea_x.duration_sec0/fea_x.newusers ELSE 0 END AS duration_sec0_pu
                ,CASE WHEN fea_x.r1users > 0 THEN fea_x.duration_sec1/fea_x.r1users ELSE 0 END AS duration_sec1_pu
                ,CASE WHEN fea_x.r2users > 0 THEN fea_x.duration_sec2/fea_x.r2users ELSE 0 END AS duration_sec2_pu
                ,CASE WHEN fea_x.r3users > 0 THEN fea_x.duration_sec3/fea_x.r3users ELSE 0 END AS duration_sec3_pu \n
        '''
        feature_query = ''
        for feature in self.features:
            for day in range(4):
                if day == 0:
                    feature_query += f',CASE WHEN fea_x.newusers > 0 THEN fea_x.{feature}0 /fea_x.newusers ELSE 0 END AS {feature}0_pu \n'
                else:
                    feature_query += f',CASE WHEN fea_x.r{day}users > 0 THEN fea_x.{feature}{day} /fea_x.r{day}users ELSE 0 END AS{feature}{day}_pu \n'
        base_sql_part2 = '''
            ,y.living_days
                ,y.sum_rev
                ,CASE WHEN fea_x.newusers > 0 THEN y.sum_rev/fea_x.newusers ELSE 0 END AS ltv
            FROM
                (SELECT 
                    create_date
                    ,first_country
                    ,campaign_name
                    ,AVG(ua_cost) ua_cost
                    ,SUM(CASE WHEN living_days = 0 THEN retended END) AS newusers 
                    ,SUM(CASE WHEN living_days = 1 THEN retended END) AS r1users 
                    ,SUM(CASE WHEN living_days = 2 THEN retended END) AS r2users 
                    ,SUM(CASE WHEN living_days = 3 THEN retended END) AS r3users 
                    ,SUM(CASE WHEN living_days = 0 THEN rev END) AS rev0 
                    ,SUM(CASE WHEN living_days = 1 THEN rev END) AS rev1 
                    ,SUM(CASE WHEN living_days = 2 THEN rev END) AS rev2 
                    ,SUM(CASE WHEN living_days = 3 THEN rev END) AS rev3 
                    ,SUM(CASE WHEN living_days = 0 THEN duration_sec END) AS duration_sec0 
                    ,SUM(CASE WHEN living_days = 1 THEN duration_sec END) AS duration_sec1 
                    ,SUM(CASE WHEN living_days = 2 THEN duration_sec END) AS duration_sec2 
                    ,SUM(CASE WHEN living_days = 3 THEN duration_sec END) AS duration_sec3 \n
        '''
        feature_query_from_mtable = ''
        for feature in self.features:
            for day in range(4):
                if day == 0:
                    feature_query_from_mtable += f',SUM(CASE WHEN living_days = 0 THEN {feature} END) AS {feature}0 \n'
                else:
                    feature_query_from_mtable += f',SUM(CASE WHEN living_days = {day} THEN {feature} END) AS {feature}{day} \n'
        base_sql_part3 = f'''
                FROM 
                    (SELECT  
                        * 
                    FROM `{self.production_id}.warehouse.campaign_review_android_median_table_di`
                    WHERE living_days BETWEEN 0 AND 3  
                    AND create_date between '{self.train_start}' and '{self.train_end}'
                    AND first_country is not null 
                    AND ua_cost>0)
                GROUP BY 1,2,3) fea_x 
            JOIN (
                SELECT 
                mix.create_date
                ,mix.campaign_name
                ,mix.first_country
                ,mix.living_days
                ,mix.sum_rev
            FROM
                (SELECT 
                    *
                    ,SUM(rev) over(partition by create_date,campaign_name,first_country 
                            order by living_days ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as sum_rev
                FROM 
                    (SELECT  
                        create_date 
                        ,campaign_name 
                        ,first_country 
                        ,living_days 
                        ,rev
                    FROM `{self.production_id}.warehouse.campaign_review_android_median_table_di`
                    WHERE first_country is not null )
                ORDER BY 1,2,3,4) mix 
            WHERE mix.living_days in ({self.train_days})) y 
            ON fea_x.create_date = y.create_date
            AND fea_x.campaign_name = y.campaign_name
            AND fea_x.first_country = y.first_country 
            where fea_x.newusers>={self.minimum_campaign_size} \n'''
        
        query = base_sql_part1 + feature_query + base_sql_part2 + feature_query_from_mtable + base_sql_part3
        return query