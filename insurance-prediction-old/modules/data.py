import pandas as pd
from sklearn.model_selection import train_test_split

class InsuranceData:
    """
    Loads the data from the given path.
    """

    def __init__(self, path, random_state=42):
        self.df = pd.read_csv(path, sep=';')
        self.random_state = random_state

    def get_raw_data(self):
        return self.df

    def get_X(self):
        X = self.df.drop(['risk', 'group', 'group_name'], axis='columns')
        return X.values

    def get_y(self):
        y = self.df['group']
        return y.values

    def get_data(self):
        X = self.get_X()
        y = self.get_y()
        return X, y

    def get_split(self, test_size=0.2):
        X = self.get_X()
        y = self.get_y()
        X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=test_size, random_state=self.random_state, stratify=y)
        return X_train, X_val, y_train, y_val