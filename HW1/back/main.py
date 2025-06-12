from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel
from typing import List
from sqlalchemy.orm import Session
from typing import Annotated
import model
from database import engine, SessionLocal

from fastapi.middleware.cors import CORSMiddleware



model.Base.metadata.create_all(bind=engine)

app = FastAPI()



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or ["http://localhost:3000"] for restricted origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ChoiceBase(BaseModel):
    choice_text: str
    is_correct: bool

class ChoiceCreate(ChoiceBase):
    pass

class ChoiceOut(ChoiceBase):
    id: int
    class Config:
        orm_mode = True

class QuestionBase(BaseModel):
    question_text: str

class QuestionCreate(QuestionBase):
    choices: List[ChoiceCreate]

class QuestionOut(QuestionBase):
    id: int
    choices: List[ChoiceOut]
    class Config:
        orm_mode = True


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session, Depends(get_db)]


@app.post("/questions/", response_model=QuestionOut)
async def create_question(question: QuestionCreate, db: db_dependency):
    db_question = model.Questions(question_text=question.question_text)
    db.add(db_question)
    db.commit()
    db.refresh(db_question)

    db_choices = []
    for choice in question.choices:
        db_choice = model.Choices(
            choice_text=choice.choice_text,
            is_correct=choice.is_correct,
            question_id=db_question.id
        )
        db.add(db_choice)
        db_choices.append(db_choice)

    db.commit()

    db_question.choices = db_choices
    return db_question


@app.get("/questions/", response_model=List[QuestionOut])
async def get_all_questions(db: db_dependency):
    questions = db.query(model.Questions).all()
    for q in questions:
        q.choices = db.query(model.Choices).filter(model.Choices.question_id == q.id).all()
    return questions


@app.get("/questions/{question_id}", response_model=QuestionOut)
async def get_question(question_id: int, db: db_dependency):
    question = db.query(model.Questions).filter(model.Questions.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    question.choices = db.query(model.Choices).filter(model.Choices.question_id == question.id).all()
    return question


@app.put("/questions/{question_id}", response_model=QuestionOut)
async def update_question(question_id: int, updated_question: QuestionCreate, db: db_dependency):
    question = db.query(model.Questions).filter(model.Questions.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

   
    question.question_text = updated_question.question_text
    db.query(model.Choices).filter(model.Choices.question_id == question_id).delete()

   
    new_choices = []
    for choice in updated_question.choices:
        new_choice = model.Choices(
            choice_text=choice.choice_text,
            is_correct=choice.is_correct,
            question_id=question_id
        )
        db.add(new_choice)
        new_choices.append(new_choice)

    db.commit()
    question.choices = new_choices
    return question


@app.delete("/questions/{question_id}")
async def delete_question(question_id: int, db: db_dependency):
    question = db.query(model.Questions).filter(model.Questions.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    db.query(model.Choices).filter(model.Choices.question_id == question_id).delete()
    db.delete(question)
    db.commit()
    return {"message": f"Question {question_id} and its choices were deleted"}
