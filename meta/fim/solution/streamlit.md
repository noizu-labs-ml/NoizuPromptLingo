# NPL-FIM: streamlit
🎈 Fast way to build and share data apps

## Installation
```bash
pip install streamlit
pip install pandas numpy matplotlib plotly
```

## Basic Usage
```python
# app.py
import streamlit as st
import pandas as pd
import numpy as np

st.title('My Data App')
st.write('## Interactive Dashboard')

# Widgets
value = st.slider('Select a value', 0, 100, 50)
st.write(f'You selected: {value}')

# Data display
df = pd.DataFrame({
    'col1': np.random.randn(100),
    'col2': np.random.randn(100)
})
st.dataframe(df)
st.line_chart(df)

# File upload
uploaded_file = st.file_uploader('Choose a CSV file')
if uploaded_file:
    df = pd.read_csv(uploaded_file)
    st.write(df)

# Columns layout
col1, col2 = st.columns(2)
with col1:
    st.header('Column 1')
    st.selectbox('Choose', ['A', 'B', 'C'])
with col2:
    st.header('Column 2')
    st.radio('Pick one', ['X', 'Y', 'Z'])

# Run: streamlit run app.py
```

## Advanced Features
```python
# Session state
if 'counter' not in st.session_state:
    st.session_state.counter = 0

if st.button('Increment'):
    st.session_state.counter += 1
st.write(f'Count: {st.session_state.counter}')

# Caching
@st.cache_data
def load_data():
    return pd.read_csv('large_file.csv')

# Plotting integration
st.pyplot(fig)  # Matplotlib
st.plotly_chart(fig)  # Plotly
st.bokeh_chart(p)  # Bokeh
st.altair_chart(chart)  # Altair
```

## Components
- Input: slider, selectbox, multiselect, text_input, number_input
- Display: write, dataframe, table, metric, json
- Charts: line_chart, area_chart, bar_chart, map
- Media: image, audio, video
- Layout: columns, expander, container, sidebar

## FIM Context
Rapid prototyping of data apps, automatic reactivity, simple deployment