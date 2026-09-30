import streamlit as st
import pandas as pd
import time
import os
import tempfile
import uuid
from sqlalchemy import create_engine, text
from langchain_community.utilities import SQLDatabase
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

st.set_page_config(page_title="AI Data Analyst 2.0", page_icon="🐙", layout="centered")

# ----------------------------------------------------------------------
# Dark theme styling to match the target design
# ----------------------------------------------------------------------
st.markdown(
    """
    <style>
        .stApp {
            background-color: #0d0d17;
            color: #f5f5f7;
        }
        [data-testid="stSidebar"] {
            background-color: #14141f;
        }
        .app-title {
            font-size: 2.1rem;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 0.1rem;
        }
        .app-subtitle {
            color: #b8b8c4;
            font-size: 1rem;
            margin-bottom: 1.6rem;
        }
        .stTextArea textarea {
            background-color: #1c1c2b;
            color: #f5f5f7;
            border: 1px solid #2e2e40;
            border-radius: 10px;
        }
        .stButton > button {
            background-color: #1c1c2b;
            color: #f5f5f7;
            border: 1px solid #3a3a4d;
            border-radius: 8px;
            padding: 0.5rem 1.4rem;
        }
        .stButton > button:hover {
            border-color: #6c6ce0;
            color: #ffffff;
        }
        label, .stMarkdown p {
            color: #e4e4ec !important;
        }
    </style>
    """,
    unsafe_allow_html=True,
)

# ----------------------------------------------------------------------
# Credentials: pulled from Streamlit secrets (.streamlit/secrets.toml)
# or environment variables. NEVER hardcode these in the script.
#
# .streamlit/secrets.toml should look like:
#
# GOOGLE_API_KEY = "your-gemini-api-key"
# DB_USER = "postgres"
# DB_PASSWORD = "your-password"
# DB_HOST = "localhost"
# DB_PORT = "5432"
# DB_NAME = "text_to_sql"
# ----------------------------------------------------------------------

def get_secret(key: str, default: str = "") -> str:
    try:
        return st.secrets.get(key, default)
    except Exception:
        # No secrets.toml file present at all - that's fine, just use the default.
        return default


@st.cache_resource(show_spinner=False)
def get_db_and_llm(connection_string: str, api_key: str, model_name: str):
    engine = create_engine(connection_string)
    db = SQLDatabase(engine)
    llm = ChatGoogleGenerativeAI(model=model_name, api_key=api_key)
    return db, llm


def build_sql_chain(db, llm):
    template = """Based on the table schema below, write a SQL query that would answer the user's question:
Remember : Only provide me the sql query dont include anything else.
           Provide me sql query in a single line dont add line breaks.
Table Schema:
{schema}

Question: {question}
SQL Query:
"""
    prompt = ChatPromptTemplate.from_template(template)

    def get_schema(_):
        return db.get_table_info()

    return (
        RunnablePassthrough.assign(schema=get_schema)
        | prompt
        | llm.bind(stop=["\nSQLResult:"])
        | StrOutputParser()
    )


# ----------------------------------------------------------------------
# Credentials come only from .streamlit/secrets.toml (or env vars) now.
# No sidebar form - keeps the UI a single clean screen.
#
# .streamlit/secrets.toml should look like:
#
# GOOGLE_API_KEY = "your-gemini-api-key"
# DB_USER = "postgres"
# DB_PASSWORD = "your-password"
# DB_HOST = "localhost"
# DB_PORT = "5432"
# DB_NAME = "text_to_sql"
# GEMINI_MODEL = "gemini-1.5-flash"
# ----------------------------------------------------------------------

db_user = get_secret("DB_USER", "postgres")
db_password = get_secret("DB_PASSWORD")
db_host = get_secret("DB_HOST", "localhost")
db_port = get_secret("DB_PORT", "5432")
db_name = get_secret("DB_NAME")
api_key = get_secret("GOOGLE_API_KEY")
model_name = get_secret("GEMINI_MODEL", "gemini-2.5-flash-lite")

if "db" not in st.session_state:
    st.session_state.db = None
    st.session_state.llm = None
    st.session_state.chain = None

# ------------------------------ Main -----------------------------------
st.markdown('<div class="app-title">🐙 AI Data Analyst 2.0</div>', unsafe_allow_html=True)
st.markdown('<div class="app-subtitle">Ask questions about your data in natural language.</div>', unsafe_allow_html=True)

if st.session_state.db is None:
    if not all([db_user, db_password, db_host, db_port, db_name, api_key]):
        st.error(
            "Missing credentials. Create a `.streamlit/secrets.toml` file next to "
            "app.py with DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME and "
            "GOOGLE_API_KEY, then rerun the app."
        )
        st.stop()
    connection_string = (
        f"postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    )
    try:
        db, llm = get_db_and_llm(connection_string, api_key, model_name)
        with db._engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        st.session_state.db = db
        st.session_state.llm = llm
        st.session_state.chain = build_sql_chain(db, llm)
    except Exception as e:
        st.error(f"Connection failed: {e}")
        st.stop()

with st.expander("Tables available in this database"):
    st.write(st.session_state.db.get_usable_table_names())

st.markdown("📄 **Or upload your own data to analyze instead:**")
uploaded_file = st.file_uploader(
    "Upload CSV",
    type=["csv"],
    label_visibility="collapsed",
    help="Uploading a file switches the app to query your file instead of the default database, just for this session.",
)

if uploaded_file is not None:
    file_id = f"{uploaded_file.name}:{uploaded_file.size}"
    if st.session_state.get("uploaded_file_id") != file_id:
        with st.spinner("Loading your file..."):
            try:
                df_upload = pd.read_csv(uploaded_file)
                table_name = "uploaded_data"
                tmp_path = os.path.join(tempfile.gettempdir(), f"tts_{uuid.uuid4().hex}.db")
                upload_engine = create_engine(f"sqlite:///{tmp_path}")
                df_upload.to_sql(table_name, upload_engine, index=False, if_exists="replace")
                upload_db = SQLDatabase(upload_engine)
                upload_llm = ChatGoogleGenerativeAI(model=model_name, api_key=api_key)
                st.session_state.db = upload_db
                st.session_state.llm = upload_llm
                st.session_state.chain = build_sql_chain(upload_db, upload_llm)
                st.session_state.uploaded_file_id = file_id
                st.session_state.pop("generated_sql", None)
                st.success(
                    f"Loaded '{uploaded_file.name}' as table `{table_name}` "
                    f"({len(df_upload)} rows, {len(df_upload.columns)} columns). "
                    "Questions below will now run against this file."
                )
            except Exception as e:
                st.error(f"Failed to load file: {e}")

st.markdown("💬 **Enter your question:**")
question = st.text_area(
    "Your question",
    placeholder="e.g., Compare total clicks and applications for October 2025",
    height=110,
    label_visibility="collapsed",
)

generate_clicked = st.button("Analyze", type="primary")

if generate_clicked and question.strip():
    sql_query = None
    last_error = None
    max_attempts = 3
    for attempt in range(max_attempts):
        try:
            with st.spinner("Generating SQL..." if attempt == 0 else f"Rate limited, retrying ({attempt}/{max_attempts - 1})..."):
                sql_query = st.session_state.chain.invoke({"question": question}).strip()
            break
        except Exception as e:
            last_error = e
            err_text = str(e)
            if "RESOURCE_EXHAUSTED" in err_text or "429" in err_text:
                if attempt < max_attempts - 1:
                    time.sleep(10)  # wait out the free-tier rate limit window
                    continue
            else:
                break  # non-rate-limit error, no point retrying

    if sql_query is not None:
        # Strip markdown code fences if the model adds them
        sql_query = sql_query.replace("```sql", "").replace("```", "").strip()
        st.session_state.generated_sql = sql_query
    elif last_error is not None:
        err_text = str(last_error)
        if "NOT_FOUND" in err_text or "404" in err_text:
            st.error(
                f"Failed to generate SQL: the model '{model_name}' isn't available "
                "for your API key. Set GEMINI_MODEL in secrets.toml to a model your "
                "key supports, e.g. 'gemini-2.5-flash-lite', 'gemini-2.5-flash' or "
                "'gemini-3-flash-preview'."
            )
        elif "RESOURCE_EXHAUSTED" in err_text or "429" in err_text:
            st.error(
                f"Failed to generate SQL: you've hit the free-tier daily quota for "
                f"model '{model_name}'. Wait a while for it to reset, switch to a "
                "model with a higher free quota (e.g. 'gemini-2.5-flash-lite') via "
                "GEMINI_MODEL in secrets.toml, or enable billing on your Google AI "
                "Studio project for higher limits."
            )
        else:
            st.error(f"Failed to generate SQL: {last_error}")

if "generated_sql" in st.session_state:
    st.subheader("Generated SQL")
    edited_sql = st.text_area("Review or edit before running:", value=st.session_state.generated_sql, height=100)

    run_col1, _ = st.columns([1, 5])
    if run_col1.button("Run query"):
        with st.spinner("Running query..."):
            try:
                df_result = pd.read_sql(edited_sql, st.session_state.db._engine)
                st.subheader("Results")
                st.dataframe(df_result, use_container_width=True)
                st.caption(f"{len(df_result)} row(s) returned.")
            except Exception as e:
                st.error(f"Query failed: {e}")
