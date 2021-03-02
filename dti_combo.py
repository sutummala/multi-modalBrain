# created by Sudhakar on September 2020
# combinational marker development using different machine learning classifiers 

import os
import numpy as np
from sklearn import metrics
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.preprocessing import MaxAbsScaler
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis as QDA
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier as kNN

import tensorflow as tf
import pickle


def compute_cutoff_auc(data1, data2, *tags):
    '''computes cut-off point and AUC for given cost and reg type from data1 (normal values), data2 (test values)'''
       
    labels = np.concatenate([np.ones(len(data1)), np.zeros(len(data2))])
    print(f'{len(data1)}, {len(data2)}')
    fpr, tpr, thresholds = metrics.roc_curve(labels, np.concatenate([data1, data2]), pos_label = 1)
    
    print(f'Threshold for {tags[2]}-{tags[1]}-{tags[3]}-{tags[0]} is: {thresholds[np.argmax(tpr-fpr)]}, sensitivity (recall) is: {tpr[np.argmax(tpr-fpr)]}, specificity is: {1-fpr[np.argmax(tpr-fpr)]}, fall-out is: {fpr[np.argmax(tpr-fpr)]}, AUC is: {metrics.auc(fpr, tpr)}\n')
    
def classifier_accuracy(model, X_train, X_test, y_train, y_test):
    'get model (classifier) accuracy based on training and testing'
    model.fit(X_train, y_train)
    return model.score(X_test, y_test), metrics.roc_auc_score(y_test, model.predict_proba(X_test)[:,1])    

def combinational_cost(data1, data2, no_of_folds):
    '''
    Parameters
    ----------
    data1 : arrays
        matrix of all costs of group1 (normal). Each individual feature should be arrnaged as a column
    data2 : arrays
        matrix of all costs of group2 (abnormal). Each individual feature should be arrnaged as a column
    no_of_folds : int
        specify number of folds for nested cross-validation
    Returns
    -------
    accuracy and AUC of the combinational cost function based on different supervised-learning classifiers for identifying mis-registrations.
    '''
    print(f'classifier comparison for DTI metrics with {no_of_folds} fold cross-validation --------------')
    
    # transposing and creating labels for data1    
    X_normal = np.transpose(data1)
    x_normal_label = np.zeros(len(X_normal))
    
    # transposing and creating labels for data2    
    X_misaligned = np.transpose(data2)
    x_misaligned_label = np.ones(len(X_misaligned))
    
    # combining data1 and data2 and the corresponding labels    
    X = np.concatenate((X_normal, X_misaligned))
    y = np.concatenate((x_normal_label, x_misaligned_label))
       
    # scaling the costs (features) to make sure the ranges of individual features are same to avoid the effect of features that have relatively large values. It may not be necessary in this case as all these 3 costs lie between 0 and 1  
    scale = MaxAbsScaler()
    X = scale.fit_transform(X)
    
    # K-fold cross validation, n_splits specifies the number of folds
    folds = StratifiedKFold(n_splits = no_of_folds)
    
    scores_lda = []
    scores_qda = [] 
    scores_rfc = []
    scores_svm = []
    scores_gnb = []
    scores_knn = []
    scores_lor = []
    scores_ada = []
    scores_gra = []
    scores_ann = []
    
    auc_lda = []
    auc_qda = [] 
    auc_rfc = []
    auc_svm = []
    auc_gnb = []
    auc_knn = []
    auc_lor = []
    auc_ada = []
    auc_gra = []
    auc_ann = []
    
    for train_index, test_index in folds.split(X, y):
        
        X_train, X_test, y_train, y_test = X[train_index], X[test_index], y[train_index], y[test_index]
    
        # 1. Linear Discriminant Analysis Classifier
        lda = LDA(solver = 'eigen', shrinkage = 'auto', n_components = 1)
        scores_lda.append(classifier_accuracy(lda, X_train, X_test, y_train, y_test)[0]) # Accuracy
        auc_lda.append(classifier_accuracy(lda, X_train, X_test, y_train, y_test)[1]) # AUC
        
        # 1a. Quadratic Discriminant Analysis Classifier
        qda = QDA()
        scores_qda.append(classifier_accuracy(qda, X_train, X_test, y_train, y_test)[0])
        auc_qda.append(classifier_accuracy(qda, X_train, X_test, y_train, y_test)[1])
        
        # 2. Random Forest Classifier (it could be done in LDA transformed space if you have large number of features)
        rfc = RandomForestClassifier(criterion = 'gini', n_estimators = 100)
        scores_rfc.append(classifier_accuracy(rfc, X_train, X_test, y_train, y_test)[0])
        auc_rfc.append(classifier_accuracy(rfc, X_train, X_test, y_train, y_test)[1])
        
        # 3. Support Vector Machine Classifier
        svc = SVC(kernel = 'rbf', gamma = 2, probability = True)
        scores_svm.append(classifier_accuracy(svc, X_train, X_test, y_train, y_test)[0])
        auc_svm.append(classifier_accuracy(svc, X_train, X_test, y_train, y_test)[1])
        
        # 4. Gaussian Naive Bayes Classifier
        gnb = GaussianNB()
        scores_gnb.append(classifier_accuracy(gnb, X_train, X_test, y_train, y_test)[0])
        auc_gnb.append(classifier_accuracy(gnb, X_train, X_test, y_train, y_test)[1])
        
        # 5. k-Nearest Neighbour Classifier
        knn = kNN(n_neighbors = 15)
        scores_knn.append(classifier_accuracy(knn, X_train, X_test, y_train, y_test)[0])
        auc_knn.append(classifier_accuracy(knn, X_train, X_test, y_train, y_test)[1])
        
        # 6. Logistic Regression Classifier
        lor = LogisticRegression()
        scores_lor.append(classifier_accuracy(lor, X_train, X_test, y_train, y_test)[0])
        auc_lor.append(classifier_accuracy(lor, X_train, X_test, y_train, y_test)[1])
        
        # 7. Ada Boost Classifier
        ada = AdaBoostClassifier(n_estimators = 100)
        scores_ada.append(classifier_accuracy(ada, X_train, X_test, y_train, y_test)[0])
        auc_ada.append(classifier_accuracy(ada, X_train, X_test, y_train, y_test)[1])
        
        # 7a. Gradient Boosting Classifier
        gra = GradientBoostingClassifier(random_state = 0)
        scores_gra.append(classifier_accuracy(gra, X_train, X_test, y_train, y_test)[0])
        auc_gra.append(classifier_accuracy(gra, X_train, X_test, y_train, y_test)[1])
        
        # 8. Arteficial Neural Network (Deep Learning)
        # model_ann = tf.keras.models.Sequential()
        # model_ann.add(tf.keras.layers.Dense(units = np.shape(X_train)[1] + 1, activation = 'relu', input_shape = (np.shape(X_train)[1],))) # input_shape takes height of the input layer which is usually fed during first dense layer allocation
        # model_ann.add(tf.keras.layers.Dense(units = np.shape(X_train)[1] + 1, activation = 'relu')) # hidden layer
        # model_ann.add(tf.keras.layers.Dense(units = np.shape(X_train)[1] + 2, activation = 'relu')) # hidden layer
        # model_ann.add(tf.keras.layers.Dense(units = np.shape(X_train)[1] + 1, activation = 'relu')) # hidden layer
        # model_ann.add(tf.keras.layers.Dense(units = 2, activation = 'softmax')) # hidden layer
        # model_ann.compile(optimizer = 'sgd', loss = 'binary_crossentropy', metrics = ['accuracy']) # compile the neural network
        # model_ann.fit(X_train, y_train, epochs = 20) # fit the neural network on the training data
        # scores_ann.append(model_ann.evaluate(X_test, y_test)) # network accuracy
        # auc_ann.append(metrics.roc_auc_score(y_test, model_ann.predict_proba(X_test)[:, 1])) # network AUC
        
    # Note: 'cross_val_score' method from sklearn could be used directly on the classifier model to avoid the above for loop. Further, f1-score could be used instead of accuracy metric if number of positive samples (mis-aligned) are low.
    
    print(f'accuracy using LDA classifier for dti measures is: {np.average(scores_lda)}, AUC is: {np.average(auc_lda)}\n')
    print(f'accuracy using QDA classifier for dti measures is: {np.average(scores_qda)}, AUC is: {np.average(auc_qda)}\n')
    print(f'accuracy using RandomForest classifier for dti measures is: {np.average(scores_rfc)}, AUC is: {np.average(auc_rfc)}\n')
    print(f'accuracy using SVM classifier for dti measures is: {np.average(scores_svm)}, AUC is: {np.average(auc_svm)}\n')
    print(f'accuracy using Naive Bayes classifier for dti measures is: {np.average(scores_gnb)}, AUC is: {np.average(auc_gnb)}\n')
    print(f'accuracy using kNN classifier for dti measures is: {np.average(scores_knn)}, AUC is: {np.average(auc_knn)}\n')
    print(f'accuracy using Logistic Regression classifier for dti measures is: {np.average(scores_lor)}, AUC is: {np.average(auc_lor)}\n')
    print(f'accuracy using Ada Boost classifier for dti measures is: {np.average(scores_ada)}, AUC is: {np.average(auc_ada)}\n')
    print(f'accuracy using Gradient boosting classifier for dti measures is: {np.average(scores_gra)}, AUC is: {np.average(auc_gra)}\n')
    #print(f'accuracy using ANN for dti measures is: {np.average(scores_ann)}, AUC is: {np.average(auc_ann)}\n')
    
    save_model = 'D:/Tummala/Parkinson-Data/ml-models-dti1000'
    
    if not os.path.exists(save_model):
        os.makedirs(save_model)
    
    # saving the trained model, e.g. shown for saving ada boost classifier model and minmax scaling model
    pickle.dump(scale, open(save_model+'/'+'scale', 'wb'))
    pickle.dump(lda, open(save_model+'/'+'lda', 'wb'))
    pickle.dump(qda, open(save_model+'/'+'qda', 'wb'))
    pickle.dump(rfc, open(save_model+'/'+'rfc', 'wb'))
    pickle.dump(svc, open(save_model+'/'+'svm', 'wb'))
    pickle.dump(gnb, open(save_model+'/'+'gnb', 'wb'))
    pickle.dump(knn, open(save_model+'/'+'knn', 'wb'))
    pickle.dump(lor, open(save_model+'/'+'lor', 'wb'))
    pickle.dump(ada, open(save_model+'/'+'ada_boost', 'wb'))
    # pickle.load method could be used to load the model for later use and predict method of the seved model to categorize new cases
    
    # # plotting ROC curve for all above classifiers
    # lda_disp = metrics.plot_roc_curve(lda, X_test, y_test)
    # qda_disp = metrics.plot_roc_curve(qda, X_test, y_test, ax = lda_disp.ax_)
    # svm_disp = metrics.plot_roc_curve(svm, X_test, y_test, ax = lda_disp.ax_)
    # #nsvm_disp = metrics.plot_roc_curve(nsvm, X_test, y_test, ax = lda_disp.ax_)
    # gnb_disp = metrics.plot_roc_curve(gnb, X_test, y_test, ax = lda_disp.ax_)
    # rfc_disp = metrics.plot_roc_curve(rfc, X_test, y_test, ax = lda_disp.ax_)
    # knn_disp = metrics.plot_roc_curve(knn, X_test, y_test, ax = lda_disp.ax_)
    # knn_disp.figure_.suptitle(f"ROC curve comparison {image_tag}-{reg_type}")

    # plt.show()
    
    # # confusion matrix and calculating the accuracy
    # cm = metrics.confusion_matrix(y_test, y_pred)
    # print(cm)
    # print('Accuracy' + str(metrics.accuracy_score(y_test, y_pred)))    