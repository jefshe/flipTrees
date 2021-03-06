context("CART")

data("spam7", package = "DAAG")
spam.sample <- spam7[sample(seq(1,4601), 500, replace=FALSE), ]
data(cola, package = "flipExampleData")
colas <- cola
data(bank, package = "flipExampleData")
bank$fOverall <- factor(bank$Overall)
levels(bank$fOverall) <- c(levels(bank$fOverall), "8")    # add an empty factor level

test_that("saving variables",
    {
        z <- CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM, data = bank,
                  subset = bank$ID > 100)
        expect_error(predict(z), NA)
        expect_error(flipData::Probabilities(z))

        z <- suppressWarnings(CART(fOverall ~ Fees + Interest + Phone + Branch + Online + ATM,
                                   data = bank, subset = bank$ID > 100))
        expect_error(predict(z), NA)
        expect_error(flipData::Probabilities(z), NA)
    })


z <- CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM, data = bank, subset = bank$ID > 100)
test_that("rpart prediction",
    {
        expect_equal(unname(predict(z)[1]), 4.258064516129032)
    })


z <- suppressWarnings(CART(fOverall ~ Fees + Interest + Phone + Branch + Online + ATM,
                           data = bank, subset = bank$ID > 100))
test_that("rpart Probabilities",
    {
        expect_equal(unname(flipData::Probabilities(z)[1, 4]), 0.2444444444444445)
    })

z <- suppressWarnings(CART(fOverall ~ Fees + Interest + Phone + Branch + Online + ATM,
                           data = bank, subset = bank$ID > 100))


# Reading in the libraries so that their outputs do not pollute the test results.
library(mice)
library(hot.deck)

test_that("Error if missing data",
{
    type = "Sankey"
    # Changing data
    expect_error((CART(yesno ~ crl.tot + dollar + bang + money + n000 + make,
                       data = spam.sample, missing = "Error if missing data")),NA)
    colas$Q32[unclass(colas$Q32) == 1] <- NA
    expect_that((CART(Q32 ~ Q2, data = colas, subset = TRUE,  missing = "Error if missing data")),
                (throws_error()))
    expect_that((CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                      data = bank, subset = TRUE,  weights = NULL, output = type, missing = "Error if missing data")), (throws_error()))
    # filter
    expect_that((CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                      data = bank, subset = bank$ID > 100,  weights = NULL, output = type, missing = "Error if missing data")), (throws_error()))
    # weight
    expect_that((CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                      data = bank, subset = TRUE,  weights = bank$ID, output = type, missing = "Error if missing data")), (throws_error()))
    # weight and filter
    expect_that((CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                      data = bank, subset = bank$ID > 100,  weights = bank$ID, missing = "Error if missing")), (throws_error()))
    # DS-1525, subset creates empty level of outcome
    expect_error(suppressWarnings(CART(Q32 ~ Q2 + Q3, data = colas, subset = colas$Q32 != "Don't know")), NA)
})


for (missing in c("Exclude cases with missing data",
                  "Use partial data",
                  "Imputation (replace missing values with estimates)"))
    for (type in c("Sankey", "Tree", "Text", "Prediction-Accuracy Table", "Cross Validation"))
        test_that(paste(missing, type),
        {
            imputation <- missing == "Imputation (replace missing values with estimates)"
            expect_error((suppressWarnings(CART(yesno ~ crl.tot + dollar + bang + money + n000 + make,
                                                data = spam.sample, subset = TRUE,  weights = NULL,
                                                output = type, missing = missing))),
                         if (imputation) NULL else NA)
            colas$Q32[unclass(colas$Q32) == 1] <- NA
            colas.small <- colas[, colnames(colas) %in% c("Q32", "Q3", "Q2", "Q4_A", "Q4_B", "Q4_C", "Q11", "Q12")]
            colas.small$Q3[1] <- NA
            expect_error((suppressWarnings(CART(Q32 ~ Q3, data = colas.small, subset = TRUE,
                                                weights = NULL, output = type, missing = missing))), NA)
            expect_error((suppressWarnings(CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                                                data = bank, subset = TRUE,  weights = NULL, output = type, missing = missing))), NA)
            # filter
            expect_error((suppressWarnings(CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                                                data = bank, subset = bank$ID > 100,  weights = NULL, output = type,
                                                missing = missing))), NA)
            # weight
            expect_error((suppressWarnings(CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                                                data = bank, subset = TRUE,  weights = bank$ID, output = type,
                                                missing = missing))), NA)
            # weight and filter
            expect_error((suppressWarnings(CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM,
                                                data = bank, subset = bank$ID > 100,  weights = bank$ID,
                                                output = type, missing = missing))), NA)
})


for (pruning in c("None", "Minimum error", "Smallest tree"))
    for (stopping in c(TRUE, FALSE))
        test_that(paste(missing, type),
            {
            expect_error((suppressWarnings(CART(Overall ~ Fees + Interest + Phone + Branch + Online + ATM, data = bank,
                                                subset = bank$ID > 100, weights = bank$ID,
                                                output = "Sankey", missing = "Exclude cases with missing data",
                                                prune = pruning, early.stopping = stopping))), NA)
})


test_that("CART: dot in formula", {
    cart <- CART(yesno ~ ., data = spam7)
    cart2 <- CART(yesno ~ crl.tot + dollar + bang + money + n000 + make, data = spam7)
    expect_equal(cart, cart2)
})

test_that("CART: many levels", {
    many.levels <- replicate(100, paste(sample(LETTERS, 2), collapse = ""))
    spam7$new <- as.factor(sample(many.levels, nrow(spam7), replace = TRUE))
    expect_error(CART(yesno ~ ., data = spam7, early.stopping = FALSE), NA)
})
