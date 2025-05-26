## **Function Descriptions**

#' Make Predictions using Logistic Regression Model
#'
#' This function takes a logistic regression model, test data, and observed outcomes as input,
#' checks for compatibility, and returns predictions along with observed outcomes.
#'
#' @param model A logistic regression model object.
#' @param test_data A data frame containing predictor variables for making predictions.
#' @param observed_outcome A numeric vector or data frame representing the observed outcomes.
#'
#' @return A list containing predictions and observed outcomes.
#'
#' @examples
#' # Example with logistic regression model, test data, and observed outcomes
#' model <- glm(formula = Outcome ~ Predictor1 + Predictor2, data = training_data, family = binomial)
#' test_data <- data.frame(Predictor1 = c(1, 2, 3), Predictor2 = c(4, 5, 6))
#' observed_outcome <- c(0, 1, 0)
#' predictions <- MakePredictions(model, test_data, observed_outcome)
#'
#' @seealso \code{\link{predict}}
#' @seealso \code{\link{glm}}
#' @seealso \code{\link{is_predictable}}
#'
#' @export
MakePredictions <- function(model, test_data, observed_outcome){
  # Custom function to check if predict works with our function
  is_predictable <- function(obj) {
    # Get all methods associated with the generic predict function
    predict_classes <- c(methods(predict))
    # Split each string at the period to get the actual model classes
    classes <- strsplit(predict_classes, "\\.")
    # Keeps only the second part of the string
    classes <- sapply(classes, function(x) x[2])
    # Check if obj inherits from any of the classes
    inherits_from_predict <- sapply(classes, function(class) inherits(obj, class))
    # Return TRUE if obj inherits from any of the classes, otherwise FALSE
    any(inherits_from_predict)
  }
  # Check if the model object class has a predict method
  if (!is_predictable(model)) {
    stop("The provided model must work with the predict function.")
  }
  # Check that the test_data object is a dataframe
  stopifnot(is.data.frame(test_data))
  # Check if the observed outcome is numeric
  stopifnot(is.numeric(observed_outcome))
  # Check if the dimensions of test data match the model expectations
  if (ncol(test_data) != ncol(model$data)-1) {
    stop("The number of predictors in the test data does not match the model.")
  }
  # Check that the length of the observed_outcome data is the same as the test_data
  if(!is.data.frame(observed_outcome)){
    if(length(observed_outcome) != nrow(test_data)){
      stop("The number of observations in the test data does not match the number of observations in the outcome data.")
    }
  }else{
    if(nrow(observed_outcome) == nrow(test_data)){
      stop("The number of observations in the test data does not match the number of observations in the outcome data.")
    }
  }
  # MAKE PREDICTIONS
  # Predict if a glm model
  if (inherits(model, "glm")){
    predictions <- predict(model, newdata = test_data, type="response")
  }else{
    stop("The model provided must be a logistic regression model (GLM)")
  }
  # Return the results (modify this based on your needs)
  return(list(
    predictions = predictions,
    observed_outcomes = observed_outcome
    # Add other results as needed
  ))
}

#' Calculate Expected Prediction Error (EPE)
#'
#' This function calculates the Expected Prediction Error (EPE) for a binary classification model.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#'
#' @return The calculated EPE
#'
#' @examples
#' calculate_EPE(unceRtain_object)
#'
#' @export
calculate_EPE = function(unceRtain_object) {
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions

  predicted_labels = ifelse(predicted_probabilities > 0.5, 1, 0)
  epe = mean(abs(predicted_labels - true_labels))

  return(paste("The Expected Prediction Error (EPE) for your binary classification model is", epe, ".",
               "\n\nEPE is a measure of the average prediction error over all possible samples.",
               "It provides an assessment of how well the binary classification model is expected to perform on new, unseen data.",
               "\n\nSmaller EPE: Indicates better predictive performance; the model's predictions are, on average, closer to the actual outcomes.",
               "\nLarger EPE: Suggests poorer predictive performance; the model's predictions deviate more from the actual outcomes."))
}

#' Set Cost of False Positive and False Negative
#'
#' This function allows you to set the cost associated with false positive and false negative predictions.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#' @param cfp Cost of false positive predictions
#' @param cfn Cost of false negative predictions
#'
#' @return The total cost based on the provided false positive and false negative costs
#'
#' @examples
#' set_cost(unceRtain_object)
#'
#' @export
set_cost = function(unceRtain_object, cfp, cfn) {
  library(pROC)
  library(ROCR)
  library(ggplot2)
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions

  predicted_labels = ifelse(predicted_probabilities > 0.5, 1, 0)

  # False Positives and False Negatives
  fp = sum((true_labels == 0) & (predicted_labels == 1))
  fn = sum((true_labels == 1) & (predicted_labels == 0))

  # Calculate cost
  total_cost = cfp * fp + cfn * fn

  return(paste("The total cost for your model is", total_cost, ".",
               "\n\nTotal Cost is a comprehensive metric that incorporates the costs associated with both false positives and false negatives.",
               "It provides a holistic view of the model's performance, considering the real-world consequences of misclassifying instances.",
               "\n\nLower Total Cost: Indicates a model configuration that minimizes the overall cost, considering both false positives and false negatives.",
               "\nHigher Total Cost: Suggests a model that may need adjustments to achieve a better balance between false positives and false negatives."))
}

#' Find Optimal Threshold for Classification
#'
#' This function determines the optimal threshold for classification based on the ROC curve.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#'
#' @return The optimal threshold for classification
#'
#' @examples
#' find_optimal_threshold(unceRtain_object)
#'
#' @export
find_optimal_threshold = function(unceRtain_object) {
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions

  roc_obj = roc(true_labels, predicted_probabilities)
  optimal_threshold = coords(roc_obj, "best")$threshold

  return(paste("The optimal threshold for your model is", optimal_threshold, ".",
               "\n\nDifferent threshold values result in different trade-offs between true positives and false positives.",
               "Determining the optimal threshold is crucial to balance sensitivity and specificity based on the specific goals and requirements of the classification task.",
               "\n\nAUC quantifies the overall performance of the model across all possible thresholds.",
               "Higher AUC values indicate better discrimination ability, but the choice of the optimal threshold depends on the application's context.",
               "\n\nAdjust the classification threshold in your model to achieve the desired balance."))
}

#' Generate ROC Curve for Model Evaluation
#'
#' This function generates the Receiver Operating Characteristic (ROC) curve, providing insights into the binary classification model's performance.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#'
#' @examples
#' generate_roc(unceRtain_object)
#'
#' @export
generate_roc = function(unceRtain_object) {
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions
  predicted_labels = round(unceRtain_object$predictions)

  # ROC Curve
  roc_obj = roc(true_labels, predicted_probabilities)
  auc_value = auc(roc_obj)

  # Print ROC Curve information
  cat("Area Under the Curve (AUC):", round(auc_value, 2), "\n")
  cat("AUC quantifies the overall performance of the model across all possible thresholds. Higher AUC values indicate better discrimination ability, but the choice of the optimal threshold depends on the application's context.\n")
  cat("The ROC curve is a graphical representation of a model's performance across various classification thresholds.\n")
  cat("It illustrates the trade-off between the true positive rate (sensitivity) and the false positive rate (1-specificity) at different threshold values.\n\n")

  # Plot ROC Curve
  plot(roc_obj, main = paste("ROC Curve (AUC =", round(auc_value, 2), ")"))
}

#' Calculate Confusion Matrix Metrics
#'
#' This function calculates the confusion matrix for a binary classification model and returns the result.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#'
#' @return A table representing the confusion matrix
#'
#' @examples
#' confusion_matrix_metrics_plot(unceRtain_object)
#'
#' @export
confusion_matrix_metrics_plot = function(unceRtain_object) {
  library(ggplot2)
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions
  predicted_labels = round(unceRtain_object$predictions)
  # Calculate confusion matrix
  confusion_matrix = table(Actual = true_labels, Predicted = predicted_labels)
  # Convert confusion matrix to data frame
  conf_matrix_df = as.data.frame(as.table(confusion_matrix))
  # Plot confusion matrix using ggplot2
  ggplot(conf_matrix_df, aes(x = Actual, y = Predicted)) +
    geom_tile(aes(fill = Freq), color = "black") +
    geom_text(aes(label = Freq), vjust = 1, color='white') +
    geom_text(aes(label = 'FP', x = 1, y = 2.2), color = "white", size = 7) +
    geom_text(aes(label = 'FN', x = 2, y = 1.2), color = "white", size = 7) +
    geom_text(aes(label = 'TP', x = 2, y =2.2), color = "white", size = 7) +
    geom_text(aes(label = 'TN', x = 1, y = 1.2), color = "white", size = 7) +
    theme_minimal()+
    labs(title = "Confusion Matrix using ggplot2",
         x = "Actual",
         y = "Predicted")
}

#' Calculate Mis-Classification Cost and Misclassification Error
#'
#' This function computes the mis-classification cost and misclassification error for a binary classification model.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#' @param cfp Cost of false positive predictions
#' @param cfn Cost of false negative predictions
#'
#' @return A list containing Misclassification Cost and Misclassification Error
#'
#' @examples
#' cfp <- 1  # Cost of False Positive
#' cfn <- 2  # Cost of False Negative
#' calculate_misclassification_cost(unceRtain_object, cfp, cfn)
#'
#' @export
calculate_misclassification_cost = function(unceRtain_object, cfp, cfn) {
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions
  predicted_labels = round(unceRtain_object$predictions)

  # False Positives and False Negatives
  fp = sum((true_labels == 0) & (predicted_labels == 1))
  fn = sum((true_labels == 1) & (predicted_labels == 0))

  # Calculate misclassification cost and 0-1 loss
  misclassification_cost = cfp * fp + cfn * fn
  misclassification_error = mean(predicted_labels != true_labels)

  cat("Misclassification Error: Represents the proportion of misclassified instances in the total dataset. It's a straightforward measure of how often the model makes mistakes. A lower misclassification error indicates better overall accuracy.\n")
  cat("Misclassification Cost: Assigns a cost to different types of misclassifications (e.g., false positives and false negatives). Provides a way to explicitly communicate the trade-off between false positives and false negatives. You can choose a threshold that minimizes the total cost rather than optimizing for accuracy alone.\n\n")

  return(list(MisclassificationCost = misclassification_cost, MisclassificationError = misclassification_error))
}

#' Calculate Classification Metrics
#'
#' This function computes classification metrics including True Positive Rate (TPR), False Positive Rate (FPR), and Precision for a binary classification model.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#'
#' @return A list containing True Positive Rate (TPR), False Positive Rate (FPR), and Precision
#'
#' @examples
#' calculate_classification_metrics(unceRtain_object)
#'
#' @export
calculate_classification_metrics = function(unceRtain_object) {
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions
  predicted_labels = round(unceRtain_object$predictions)

  tp = sum((true_labels == 1) & (predicted_labels == 1))
  tn = sum((true_labels == 0) & (predicted_labels == 0))
  fp = sum((true_labels == 0) & (predicted_labels == 1))
  fn = sum((true_labels == 1) & (predicted_labels == 0))

  tpr = tp / (tp + fn)  # True Positive Rate (Sensitivity)
  fpr = fp / (fp + tn)  # False Positive Rate
  precision = tp / (tp + fp)

  cat("TPR focuses on the model's ability to correctly identify positive instances, emphasizing sensitivity.It is calculated as the ratio of true positives to the sum of true positives and false negatives.TPR provides insight into the model's ability to correctly identify positive instances among all actual positive instances.\n")
  cat("FPR focuses on the model's tendency to incorrectly identify negative instances as positive, providing insight into specificity. It is calculated as the ratio of false positives to the sum of false positives and true negatives.FPR is complementary to specificity (true negative rate) and is important in understanding how well a model distinguishes negative instances.\n")
  cat("Precision emphasizes the accuracy of positive predictions made by the model. It is calculated as the ratio of true positives to the sum of true positives and false positives. It is especially relevant when the cost of false positives is high, and it quantifies the accuracy of the positive predictions made by the model.\n\n")

  return(list(TPR = tpr, FPR = fpr, Precision = precision))
}

#' Generate Confusion Matrix Visualization
#'
#' This function generates a visualization for the confusion matrix.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#'
#' @examples
#' generate_confusion_matrix_visualization(unceRtain_object)
#'
#' @export
generate_confusion_matrix_visualization = function(unceRtain_object) {
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions
  predicted_labels = round(unceRtain_object$predictions)

  # Confusion Matrix
  confusion_matrix = confusion_matrix_metrics_plot(true_labels, predicted_labels)

  cat("A confusion matrix is a tabular representation of the model's predictions, including true positives, true negatives, false positives, and false negatives.\n")
  cat("The visual representation allows you to quickly assess how well the model is performing in terms of correctly and incorrectly classified instances.\n")
  cat("This can help in selecting an optimal threshold by showing the impact on the confusion matrix at different threshold values.\n\n")

  # Visualization
  print("Confusion Matrix:")
  print(confusion_matrix)
}

#' Generate ROC Curve Visualization
#'
#' This function generates a visualization for the ROC curve.
#'
#' @param unceRtain_object An object created using the MakePrediction() function
#'
#' @examples
#' generate_roc_curve_visualization(unceRtain_object)
#'
#' @export
generate_roc_curve_visualization <- function(unceRtain_object){
  true_labels <- unceRtain_object$observed_outcome
  predicted_probabilities <- unceRtain_object$predictions
  roc_obj <- roc(true_labels, predicted_probabilities)
  auc_value = auc(roc_obj)

  cat("AUC quantifies the overall performance of the model across all possible thresholds. Higher AUC values indicate better discrimination ability, but the choice of the optimal threshold depends on the application's context.\n")
  cat("The ROC curve is a graphical representation of a model's performance across various classification thresholds.\n")
  cat("It illustrates the trade-off between the true positive rate (sensitivity) and the false positive rate (1-specificity) at different threshold values.\n\n")

  # Visualization
  plot(roc_obj, main = paste("ROC Curve (AUC =", round(auc_value, 2), ")"))
}

library(devtools)
library(roxygen2)

# this function generates documentation based on the in-code comments above
devtools::document()
