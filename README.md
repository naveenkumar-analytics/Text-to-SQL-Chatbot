# 🗣️ Text-to-SQL Chatbot

Ask questions about your sales data in plain English and get answers instantly, no SQL required.

> Built with **Google Gemini + LangChain + PostgreSQL + Streamlit**

![Demo](assets/demo.gif)

## 🎯 Problem

Business teams often depend on analysts for simple data questions like
*"Which region had the highest sales in 2017?"*. This chatbot removes that
bottleneck: it converts a natural-language question into SQL, runs it on a
PostgreSQL database, and returns the answer in plain English.

## ✨ Features

- **Natural language → SQL** using Google Gemini via LangChain
- **Schema-grounded prompts:** table and column details are passed to the LLM so generated queries stay accurate to the real database structure
- **PostgreSQL integration:** executes the generated query and fetches results
- **Plain-English answers:** results are summarized back to the user
- **Safety guardrails:** only `SELECT` queries are allowed (blocks `DROP`, `DELETE`, `UPDATE`, etc.)
- **Multi-table JOINs** across Sales Orders, Customers, Products, Regions and State Regions
- **Streamlit chat interface** for easy use by non-technical users

## 💬 Example Queries

| Question | Generated SQL | Answer |
|---|---|---|
| Top 5 customers by revenue? | `SELECT ...` | ... |
| Which state has the most orders? | `SELECT ...` | ... |
| Total sales by region in 2017? | `SELECT ...` | ... |

## 🏗️ Architecture

![Architecture](assets/architecture.png)

```
User question
   → Prompt + DB schema context
   → Gemini (LLM chain)
   → SQL query (validated: SELECT only)
   → PostgreSQL
   → Result
   → Natural-language answer
```

| Component | Role |
|---|---|
| **Data source** | CSV files in `data/` (Sales Orders, Customers, Products, Regions, State Regions, 2017 Budgets) |
| **Database** | PostgreSQL, managed and loaded using pgAdmin 4 |
| **LLM chain** | LangChain + Gemini converts questions to SQL |
| **Output parser** | Cleans the SQL and formats results for display |
| **UI** | Streamlit |

## 📊 Evaluation

| Metric | Result |
|---|---|
| Test questions | 25 |
| Correct SQL generated | XX% |
| Avg. response time | X.X sec |

**Where it fails:** (e.g., ambiguous column names, complex nested queries) and how I improved it.

## 🧠 Challenges & Learnings

- **Prompt engineering:** adding schema context and few-shot examples improved accuracy from X% to Y%
- **Hallucinated columns:** reduced by grounding the prompt in the actual table structure
- **Unsafe SQL:** added a validation layer that only allows read-only queries
- **PostgreSQL syntax:** tuned the prompt so the LLM generates PostgreSQL-compatible SQL (e.g., date functions, quoting)

## 🛠️ Setup

**1. Clone the repository**
```bash
git clone https://github.com/naveenkumar-analytics/Text-to-SQL-Chatbot.git
cd Text-to-SQL-Chatbot
pip install -r requirements.txt
```

**2. Set up PostgreSQL**
- Open **pgAdmin 4** and create a new database (e.g., `sales_db`)
- Create the tables using the scripts in `sql/`
- Load the CSV files from `data/` into the tables (pgAdmin: right-click table → *Import/Export Data*)

**3. Configure environment variables**

Create a `.env` file:
```
GOOGLE_API_KEY=your_gemini_api_key
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sales_db
DB_USER=postgres
DB_PASSWORD=your_password
```

**4. Run the app**
```bash
streamlit run app.py
```

## 📁 Project Structure

```
├── data/        # Source CSV files
├── notebooks/   # Gemini chatbot experiments (Gemini_chatbot.ipynb)
├── sql/         # Table creation scripts
├── app          # Streamlit app
├── requirements.txt
└── LICENSE
```

## 🚀 Future Work

- Compare accuracy across multiple LLMs (GPT, Llama, Gemini)
- Query caching and chart generation for results
- Cloud deployment (Streamlit Community Cloud)

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 👤 Author

**Naveen Kumar**
B.Tech, NIT Andhra Pradesh 

[LinkedIn](https://linkedin.com/in/naveen-kumarofficial) | [Email](mailto:n9306578329@gmail.com) | [GitHub](https://github.com/naveenkumar-analytics)
