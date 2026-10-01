# 🗣️ Text-to-SQL Chatbot

Ask questions about your sales data in plain English and get answers instantly, no SQL required.

> Built with **Google Gemini + LangChain + MySQL + Streamlit**

![Demo](assets/demo.gif)

## 🎯 Problem
Business teams depend on analysts for simple data questions like
"Which region had the highest sales in 2017?". This chatbot removes that
bottleneck by converting natural language to SQL and returning the answer.

## ✨ Features
- Natural language → SQL using Gemini
- Runs queries on MySQL and returns results in plain English
- **Safety guardrails:** only SELECT queries allowed (blocks DROP/DELETE/UPDATE)
- Handles multi-table JOINs (Sales, Customers, Products, Regions)
- Streamlit chat interface

## 💬 Example Queries
| Question | Generated SQL | Answer |
|---|---|---|
| Top 5 customers by revenue? | `SELECT ...` | ... |
| Which state has most orders? | `SELECT ...` | ... |
| Total sales by region in 2017? | `SELECT ...` | ... |

## 🏗️ Architecture
![Architecture](assets/architecture.png)

User question → Prompt + DB schema → Gemini → SQL → MySQL → Result → Natural-language answer

## 📊 Evaluation
| Metric | Result |
|---|---|
| Test questions | 25 |
| Correct SQL | XX% |
| Avg response time | X.X sec |

**Where it fails:** (e.g., ambiguous column names, complex nested queries) and how I improved it.

## 🧠 Challenges & Learnings
- Prompt engineering: adding table schema + few-shot examples improved accuracy from X% to Y%
- Preventing hallucinated column names
- Blocking unsafe SQL

## 🛠️ Setup
```bash
git clone https://github.com/naveenkumar-analytics/Text-to-SQL-Chatbot.git
cd Text-to-SQL-Chatbot
pip install -r requirements.txt
# add GOOGLE_API_KEY in .env, load data/ CSVs into MySQL (see sql/)
streamlit run app.py
```

## 📁 Project Structure
- `data/` – source CSVs
- `sql/` – table creation scripts
- `notebooks/` – Gemini experiments
- `app` – Streamlit app

## 🚀 Future Work
- Support for more LLMs (GPT, Llama) and compare accuracy
- Query caching, chart generation for results
- Cloud deployment

## 👤 Author
**Naveen Kumar**: [LinkedIn](link) | [Email](mail)
