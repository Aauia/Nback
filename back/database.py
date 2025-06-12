from sqlalchemy import create_engine 
from sqlalchemy.orm import sessionmaker
from sqlalchemy. ext.declarative import declarative_base


URL_DATABASE = "postgresql://postgres:2006@localhost:5432/QuizeAppl"



engine = create_engine(URL_DATABASE)


SessionLocal = sessionmaker (autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()