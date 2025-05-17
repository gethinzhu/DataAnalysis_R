# Define UI for the Shiny app
ui <- fluidPage(
  titlePanel("Visualization for Project"),
  sidebarLayout(
    sidebarPanel(
      selectInput("section", "Select Section:", choices = c("Data Preparation and Exploration", "Classification", "Clustering")),
      conditionalPanel(
        condition = "input.section == 'Data Preparation and Exploration'",
        selectInput("selected_entity", "Select a Country:", choices = c("All", unique(data$Entity)), selected = "All"),
        selectInput("eda_type", "Select EDA type:", choices = c("EDA Single Variables", "EDA Multiple Variables")),
        conditionalPanel(
          condition = "input.eda_type == 'EDA Single Variables'",
          selectInput("plot_type", "Select Plot Type:", choices = c("Histogram", "Density Plot", "Boxplot")),
          selectInput("selected_variable", "Select Variable:", choices = c("Year", "death.rate", "gdp.pcap", "population"))
        ),
        conditionalPanel(
          condition = "input.eda_type == 'EDA Multiple Variables'",
          selectInput("multiple_plot_type", "Select Plot Type:", choices = c("Scatter Plot Matrix", "Scatter and Smooth Plot", "Hexbin Plot")),
          conditionalPanel(
            condition = "input.multiple_plot_type == 'Scatter Plot Matrix'",
            checkboxGroupInput("scatter_variables", "Select Variables:", choices = c("Year", "death.rate", "gdp.pcap", "population"), selected = c("Year", "death.rate", "gdp.pcap", "population"))
          ),
          conditionalPanel(
            condition = "input.multiple_plot_type == 'Scatter and Smooth Plot' || input.multiple_plot_type == 'Hexbin Plot'",
            selectInput("x_variable", "Select X-axis Variable:", choices = c("Year", "death.rate", "gdp.pcap", "population")),
            selectInput("y_variable", "Select Y-axis Variable:", choices = c("Year", "death.rate", "gdp.pcap", "population")),
            conditionalPanel(
              condition = "input.x_variable == 'Year'",
              sliderInput("year_range", "Select Year Range:", min = min(data$Year), max = max(data$Year), value = c(min(data$Year), max(data$Year)), step = 1)
            )
          )
        )
      ),
      conditionalPanel(
        condition = "input.section == 'Classification'",
        selectInput("classification_plot", "Select Plot:", choices = c("Visualize Decision Tree Model", "Decision Tree ROC Curve", "Logistic Regression ROC Curve", "LIME Explanation of Decision Tree Model", "LIME Explanation of Logistic Regression Model"))
      ),
      conditionalPanel(
        condition = "input.section == 'Clustering'",
        selectInput("clustering_plot", "Select Plot:", choices = c("CH Index and ASW", "Clustering Results (k=2)", "Clustering Results (k=3)", "Clustering Results (k=9)"))
      )
    ),
    mainPanel(
      plotOutput("dynamic_plot")
    )
  )
)

# Define server logic for the Shiny app
server <- function(input, output) {
  output$dynamic_plot <- renderPlot({
    if (input$section == "Data Preparation and Exploration") {
      # Filter data for specific country
      if (input$selected_entity == "All") {
        filtered_data <- data
      } else {
        filtered_data <- data %>% filter(Entity == input$selected_entity)
      }
      
      # Plot based on different EDA types
      if (input$eda_type == "EDA Single Variables") {
        if (input$plot_type == "Histogram") {
          ggplot(filtered_data, aes_string(x = input$selected_variable)) +
            geom_histogram(fill = "lightblue", bins = 30) +
            labs(title = paste("Histogram of", input$selected_variable, "for", input$selected_entity),
                 x = input$selected_variable) +
            theme_minimal()
          
        } else if (input$plot_type == "Density Plot") {
          ggplot(filtered_data, aes_string(x = input$selected_variable)) +
            geom_density(fill = "lightblue") +
            labs(title = paste("Density Plot of", input$selected_variable, "for", input$selected_entity),
                 x = input$selected_variable) +
            theme_minimal()
          
        } else if (input$plot_type == "Boxplot") {
          ggplot(filtered_data, aes_string(y = input$selected_variable)) +
            geom_boxplot(fill = "lightblue") +
            labs(title = paste("Boxplot of", input$selected_variable, "for", input$selected_entity),
                 y = input$selected_variable) +
            theme_minimal()
        }
      } else if (input$eda_type == "EDA Multiple Variables") {
        if (input$multiple_plot_type == "Scatter Plot Matrix") {
          # Generate Scatter Plot Matrix using selected variables
          selected_vars <- input$scatter_variables
          if (length(selected_vars) > 1) {
            formula <- as.formula(paste("~", paste(selected_vars, collapse = "+")))
            pairs(formula, data = filtered_data)
          } else {
            showNotification("Please select at least two variables for the Scatter Plot Matrix.", type = "error")
          }
          
        } else if (input$multiple_plot_type == "Scatter and Smooth Plot") {
          if (input$x_variable == "Year") {
            filtered_data <- filtered_data %>% filter(Year >= input$year_range[1] & Year <= input$year_range[2])
          }
          ggplot(filtered_data, aes_string(x = input$x_variable, y = input$y_variable)) +
            geom_point() +
            geom_smooth(method = "loess", se = FALSE, color = "red") +
            labs(title = paste("Scatter and Smooth Plot of", input$y_variable, "vs", input$x_variable, "for", input$selected_entity),
                 x = input$x_variable,
                 y = input$y_variable) +
            theme_minimal()
          
        } else if (input$multiple_plot_type == "Hexbin Plot") {
          if (input$x_variable == "Year") {
            filtered_data <- filtered_data %>% filter(Year >= input$year_range[1] & Year <= input$year_range[2])
          }
          ggplot(filtered_data, aes_string(x = input$x_variable, y = input$y_variable)) +
            geom_hex(bins = 30) +
            labs(title = paste("Hexbin Plot of", input$y_variable, "vs", input$x_variable, "for", input$selected_entity),
                 x = input$x_variable,
                 y = input$y_variable) +
            theme_minimal()
        }
      }
    } else if (input$section == "Classification") {
      if (input$classification_plot == "Visualize Decision Tree Model") {
        # Visualize Decision Tree Model
        rpart.plot(tree_model)
      } else if (input$classification_plot == "Decision Tree ROC Curve") {
        # Plot Decision Tree ROC Curve
        plot(tree_train_perf, col = "green", lwd = 2, main = "ROC Curves for Tree Decision Model")
        plot(tree_test_perf, col = "blue", lwd = 2, add = TRUE)
        plot(null_perf, col = "red", lwd = 2, add = TRUE)
        legend("bottomright", legend = c("Train Data", "Test Data", "Null Model"), col = c("green", "blue", "red"), lwd = 2)
      } else if (input$classification_plot == "Logistic Regression ROC Curve") {
        # Plot Logistic Regression ROC Curve
        plot(logit_train_perf, col = "green", lwd = 2, main = "ROC Curves for Logistic Regression Model")
        plot(logit_test_perf, col = "blue", lwd = 2, add = TRUE)
        plot(null_perf, col = "red", lwd = 2, add = TRUE)
        legend("bottomright", legend = c("Train Data", "Test Data", "Null Model"), col = c("green", "blue", "red"), lwd = 2)
      } else if (input$classification_plot == "LIME Explanation of Decision Tree Model") {
        # Plot LIME Explanation for Decision Tree Model
        plot_features(explanation_tree)
      } else if (input$classification_plot == "LIME Explanation of Logistic Regression Model") {
        # Plot LIME Explanation for Logistic Regression Model
        plot_features(explanation_logit)
      }
    } else if (input$section == "Clustering") {
      if (input$clustering_plot == "CH Index and ASW") {
        # Plot CH Index and ASW
        grid.arrange(fig1, fig2, nrow = 1)
      } else if (input$clustering_plot == "Clustering Results (k=2)") {
        # Plot Clustering Results for k=2
        ggplot(cluster_data_2, aes(x = population, y = gdp.pcap, color = cluster)) +
          geom_point(size = 2) +
          labs(title = "K-Means Clustering Results (k=2)",
               x = "Population",
               y = "GDP per Capita") +
          theme_minimal()
      } else if (input$clustering_plot == "Clustering Results (k=3)") {
        # Plot Clustering Results for k=3
        ggplot(cluster_data_3, aes(x = population, y = gdp.pcap, color = cluster)) +
          geom_point(size = 2) +
          labs(title = "K-Means Clustering Results (k=3)",
               x = "Population",
               y = "GDP per Capita") +
          theme_minimal()
      } else if (input$clustering_plot == "Clustering Results (k=9)") {
        # Plot Clustering Results for k=9
        ggplot(cluster_data_9, aes(x = population, y = gdp.pcap, color = cluster)) +
          geom_point(size = 2) +
          labs(title = "K-Means Clustering Results (k=9)",
               x = "GDP per Capita",
               y = "Death Rate") +
          theme_minimal()
      }
    }
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
