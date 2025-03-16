import pandas as pd

# Load dataset
df = pd.read_csv("rotten_tomatoes_critic_reviews.csv")

# Print available columns (for debugging)
print("Available Columns:", df.columns)

# Select relevant columns
selected_columns = ["critic_name", "review_content", "review_score", "review_type"]
df = df[selected_columns]

# Show first few rows
print(df.head())


