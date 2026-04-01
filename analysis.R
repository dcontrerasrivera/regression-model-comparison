# =========================

# Load Data

# =========================

trout <- read.csv("data/trout.csv")

# =========================

# Linear Regression

# =========================

linear_model <- lm(Weight ~ Length, data = trout)

plot(trout$Length, trout$Weight,
xlab = "Length (mm)",
ylab = "Weight (grams)",
main = "Linear Regression Fit")

abline(linear_model, col = "blue", lwd = 2)

# =========================

# LOOCV - Linear Regression

# =========================

n <- nrow(trout)
errors <- numeric(n)

for (i in 1:n) {
train <- trout[-i, ]
test  <- trout[i, ]

model <- lm(Weight ~ Length, data = train)
pred  <- predict(model, newdata = test)

errors[i] <- (test$Weight - pred)^2
}

linear_loocv <- sqrt(mean(errors))

# =========================

# 5-Fold CV - Linear Regression

# =========================

k <- 5
folds <- sample(rep(1:k, length.out = n))

for (j in 1:k) {
test_idx <- which(folds == j)

train <- trout[-test_idx, ]
test  <- trout[test_idx, ]

model <- lm(Weight ~ Length, data = train)
pred  <- predict(model, newdata = test)

errors[test_idx] <- (test$Weight - pred)^2
}

linear_kfold <- sqrt(mean(errors))

# =========================

# Kernel Regression

# =========================

x <- trout$Length
y <- trout$Weight
h <- 30

kernel_fit <- function(x0, x, y, h) {
w <- exp(-0.5 * ((x0 - x)/h)^2)
sum(w * y) / sum(w)
}

xgrid <- seq(min(x), max(x), length.out = 200)
yhat  <- sapply(xgrid, kernel_fit, x = x, y = y, h = h)

plot(x, y,
xlab = "Length (mm)",
ylab = "Weight (grams)",
main = "Kernel Regression")

lines(xgrid, yhat, col = "red", lwd = 2)

# LOOCV - Kernel

for (i in 1:n) {
x_train <- x[-i]
y_train <- y[-i]

w <- exp(-0.5 * ((x[i] - x_train)/h)^2)
pred <- sum(w * y_train) / sum(w)

errors[i] <- (y[i] - pred)^2
}

kernel_loocv <- sqrt(mean(errors))

# =========================

# Polynomial Regression

# =========================

trout$Length2 <- trout$Length^2

poly_model <- lm(Weight ~ Length + Length2, data = trout)

xgrid <- seq(min(trout$Length), max(trout$Length), length = 200)

yhat <- predict(poly_model,
newdata = data.frame(
Length = xgrid,
Length2 = xgrid^2
))

plot(trout$Length, trout$Weight,
xlab = "Length (mm)",
ylab = "Weight (grams)",
main = "Polynomial Regression")

lines(xgrid, yhat, col = "blue", lwd = 2)

# LOOCV - Polynomial

for (i in 1:n) {
train <- trout[-i, ]
test  <- trout[i, ]

model <- lm(Weight ~ Length + I(Length^2), data = train)
pred  <- predict(model, newdata = test)

errors[i] <- (test$Weight - pred)^2
}

poly_loocv <- sqrt(mean(errors))

# =========================

# Summary of Results

# =========================

results <- data.frame(
Model = c("Linear", "Kernel", "Polynomial"),
LOOCV_Error = c(linear_loocv, kernel_loocv, poly_loocv)
)

print(results)
