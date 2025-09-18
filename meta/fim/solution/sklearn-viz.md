# NPL-FIM: sklearn-viz
🤖 Machine learning visualization tools from scikit-learn

## Installation
```bash
pip install scikit-learn
pip install matplotlib  # Required for plotting
pip install pandas numpy  # Recommended
```

## Basic Usage
```python
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import ConfusionMatrixDisplay, RocCurveDisplay
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

# Load data
iris = datasets.load_iris()
X, y = iris.data, iris.target
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)

# Train model
clf = RandomForestClassifier()
clf.fit(X_train, y_train)

# Confusion matrix
ConfusionMatrixDisplay.from_estimator(clf, X_test, y_test)
plt.show()

# ROC curve (binary classification)
from sklearn.svm import SVC
binary_y = (y == 0).astype(int)
svm = SVC(probability=True)
svm.fit(X_train, binary_y[train_test_split(range(len(y)), test_size=0.3)[0]])
RocCurveDisplay.from_estimator(svm, X_test, binary_y[train_test_split(range(len(y)), test_size=0.3)[1]])
plt.show()
```

## Visualization Functions
```python
# Model evaluation
from sklearn.metrics import plot_confusion_matrix  # Deprecated, use ConfusionMatrixDisplay
from sklearn.metrics import plot_roc_curve  # Deprecated, use RocCurveDisplay
from sklearn.metrics import plot_precision_recall_curve  # Deprecated, use PrecisionRecallDisplay

# Feature importance
importances = clf.feature_importances_
plt.barh(range(len(importances)), importances)
plt.yticks(range(len(importances)), iris.feature_names)
plt.xlabel('Importance')
plt.show()

# Decision boundaries
from sklearn.inspection import DecisionBoundaryDisplay
DecisionBoundaryDisplay.from_estimator(clf, X[:, :2], alpha=0.5)
plt.scatter(X[:, 0], X[:, 1], c=y, edgecolors='k')
plt.show()

# Partial dependence plots
from sklearn.inspection import PartialDependenceDisplay
PartialDependenceDisplay.from_estimator(clf, X_train, features=[0, 1])
plt.show()
```

## Dimensionality Reduction Viz
```python
# PCA visualization
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)
plt.scatter(X_pca[:, 0], X_pca[:, 1], c=y, cmap='viridis')
plt.xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.2%})')
plt.ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.2%})')

# t-SNE
from sklearn.manifold import TSNE
tsne = TSNE(n_components=2)
X_tsne = tsne.fit_transform(X)
plt.scatter(X_tsne[:, 0], X_tsne[:, 1], c=y)
```

## Model Inspection
```python
# Learning curves
from sklearn.model_selection import learning_curve
train_sizes, train_scores, val_scores = learning_curve(clf, X, y, cv=5)
plt.plot(train_sizes, train_scores.mean(axis=1), label='Training')
plt.plot(train_sizes, val_scores.mean(axis=1), label='Validation')
plt.legend()

# Validation curves
from sklearn.model_selection import validation_curve
param_range = [1, 10, 100]
train_scores, val_scores = validation_curve(
    clf, X, y, param_name='n_estimators', param_range=param_range, cv=5)
```

## FIM Context
ML-specific visualizations for model evaluation, feature analysis, and diagnostics