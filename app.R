# By Daniel Redondo and Miguel Angel Luque-Fernandez
 
library(shiny)
library(shinythemes)
library(ggplot2)
library(dplyr)
library(readr) # For "write_csv" function
library(visreg) # Model visualization

generateData <- function(alpha1, alpha2, n){
    sodium  <- rnorm(n, 3.50, 0.50) 
    age <- sodium * 18 + rnorm(n)
    sbp <- 2.25 * sodium + 2.00 * age + rnorm(n)
    proteinuria  <-  alpha1 * sodium + alpha2 * sbp + 0.9 * age + rnorm(n)
    data.frame(sbp, age, sodium, proteinuria)
}


# UI -------------------------------
ui <- fluidPage(theme = shinytheme("cosmo"),
      titlePanel(HTML("<b>Colliders in Epidemiology: an educational interactive web application</b>"), windowTitle = "Collider"),
      tabsetPanel(
        # Tab 1: Motivation -------------------------------
        tabPanel("Motivation", br(), br(),
                 fluidRow(
                     column(5, div(img(src = "logo.png", width = "80%"), style = "text-align: center;")),
                     column(7,
                            
                            h3(tags$b("Correlation is not causation")),
                            
                            h4("During the last 30 years, classical epidemiology has focussed on the control of confounding [1]. However, it
                               is only recently that epidemiologists have started to focus on the bias produced by colliders and mediators
                               in addition to confounders [2, 3]. In the epidemiological literature different explanations have been
                               proposed to describe the paradoxical protective effect of established risk factors. Such as, for example,
                               the protective effect of maternal smoking on infant mortality and the incidence of pre-eclampsia, namely
                               the birth weight and the smoking pre-eclampsia paradoxes [4, 5].", style = "text-align: justify;"),
                            
                            hr(),
                            
                            h3(tags$b("What is a collider?")),
                            
                            h4("A collider for a certain pair of variables (outcome and exposure) is a third variable that
                               is influenced by both of them. Controlling for, or conditioning the analysis on (i.e., stratiffication or
                               regression) a collider, can introduce a spurious association between its causes (exposure and outcome)
                               potentially explaining why the medical literature is full of paradoxical findings [6]. In DAG terminology,
                               a collider is the variable in the middle of an inverted fork (i.e., variable W in A -> W <- Y) [7]. While this methodological
                               note will not close the vexing gap between correlation and causation, but
                               it will contribute to the increasing awareness and the general understanding of colliders among applied
                               epidemiologists and medical researchers.", style = "text-align: justify;"),
                            
                            hr(),
                            
                            h3(tags$b("Objective")),
                            
                            h4("To illustrate with an educational purpose the effect of conditioning on a collider based on a realistic non-communicable disease
                                epidemiology example (hypertension and dietary sodium intake).
                                We estimate the effect of 24-hour dietary sodium intake in grams (exposure) on systolic blood pressure (outcome)
                                accounting for the effect of age (confounder). The objective of the illustration is to show the paradoxical effect of
                                24-hour dietary sodium intake on systolic blood pressure after conditioning on 24-hour excretion of urinary protein (collider).
                               ", style = "text-align: justify;"),
                            
                            hr(),

                            h3(tags$b("References")),
                            
                            h5("[1] Sander Greenland and Hal Morgenstern. Confounding in health research. Annual Review of Public Health, 22(1):189-212, May 2001.",
                               br(), br(),
                               "[2] Stephen R Cole, RobertWPlatt, Enrique F Schisterman, Haitao Chu, DanielWestreich, David Richardson, and Charles
                                Poole. Illustrating bias due to conditioning on a collider. International Journal of Epidemiology, 39(2):417-420, Nov 2009.",
                               br(), br(),
                               "[3] Tyler J. Vanderweele and Stijn Vansteelandt. Conceptual issues concerning mediation, interventions and composition.
                                    Statistics and Its Interface, 2(4):457-468, 2009.",
                               br(), br(),
                               "[4] Miguel Angel Luque-Fernandez, Helga Zoega, Unnur Valdimarsdottir, and Michelle A. Williams. Deconstructing the
                                        smoking-preeclampsia paradox through a counterfactual framework. European Journal of Epidemiology, 31(6):613-623, Jun 2016.",
                               br(), br(),
                               "[5] S. Hernandez-Diaz, E. F. Schisterman, and M. A. Hernan. The birth weight ''paradox'' uncovered? American Journal
                                            of Epidemiology, 164(11):1115-1120, Sep 2006.",
                               br(), br(),
                               "[6] Julia M Rohrer. Thinking clearly about correlations and causation: Graphical causal models for observational data. 2017.",
                               br(), br(),
                               "[7] Judea Pearl. Causal diagrams for empirical research. Biometrika, 82(4):669-688, 1995.",
                               style = "text-align: justify;")
                     )
                )
            ),
        
        # Tab 2: Code for data generation -------------------------------
        tabPanel("Data generation",
                 h2(tags$b("Data generation")), br(),
                 fluidRow(column(6,
                                 
                                 h4(tags$b("Data generation process")),
                                 p("Based on a motivating example in non-communicable disease epidemiology, we generated a dataset with
                                   1,000 observations to contextualize the effect of conditioning on a collider. High blood pressure is one of the most common comorbidities.
                                   Nearly 1 in 3 Americans suffer from high blood pressure and more than half do not have it under control
                                   [1]. Sustained levels of systolic blood pressure over time are associated with increased cardio-vascular
                                   morbidity and mortality [2]. Summative evidence shows that exceeding the recommendations for 24-
                                   hour dietary sodium intake in grams is associated with increased levels of systolic blood pressure (SBP)
                                   in mmHg [3]. SBP is associated with increasing age [4]. Thus, age in years is a confounder for the
                                   association between sodium intake and SBP. However, high levels of 24-hour excretion of urinary protein
                                   (proteinuria) are associated with sustained high SBP, advanced age and increased 24-hour dietary sodium
                                   intake. Therefore, proteinuria (PRO in the DAG) acts as a collider."),
                                 
                                 p("The data generation for the simulation is based on the structural relationship between the variables depicted on the Directed Acyclic Graph.
                                   We assumed that SBP increases with increasing age and dietary
                                   sodium intake. We simulated 24-hour excretion of urinary protein as a function of age, SBP, and
                                   sodium intake. We assured that the range of values of the simulated data was biologically plausible and as
                                   close to reality as possible [4, 5]."),
                                 
                                 h4(tags$b("References")),
                                 
                                 h5("[1] Emelia J Benjamin, Michael J Blaha, Stephanie E Chiuve, Mary Cushman, Sandeep R Das, Rajat Deo,
                                    J Floyd, M Fornage, C Gillespie, CR Isasi, et al. Heart disease and stroke statistics-2017 update: a report from
                                    the american heart association. Circulation, 135(10):e146-e603, 2017.",
                                    br(), br(),
                                    "[2] Qiuping Gu, Vicki L Burt, Ryne Paulose-Ram, Sarah Yoon, and Richard F Gillum. High blood pressure and
                                    cardio-vascular disease mortality risk among us adults: the third national health and nutrition examination
                                    survey mortality follow-up study. Annals of epidemiology, 18(4):302-309, 2008.",
                                    br(), br(),
                                    "[3] Frank M Sacks, Laura P Svetkey, William M Vollmer, Lawrence J Appel, George A Bray, David Harsha,
                                    Eva Obarzanek, Paul R Conlin, Edgar R Miller, Denise G Simons-Morton, et al. Effects on blood pressure of
                                    reduced dietary sodium and the dietary approaches to stop hypertension (dash) diet. New England journal
                                    of medicine, 344(1):3-10, 2001.",
                                    br(), br(),
                                    "[4] Linda Van Horn, Jo Ann S Carson, Lawrence J Appel, Lora E Burke, Christina Economos, Wahida Karmally et al.
                                    Recommended dietary pattern to achieve adherence to the american
                                    heart association/american college of cardiology (aha/acc) guidelines: A scientific statement from the american heart
                                    association. Circulation, 134(22):e505e529, Nov 2016.",
                                    br(), br(),
                                    "[5] Michael F Carroll. Proteinuria in adults: A diagnostic approach. American family physician, 62(6), 2000.",
                                    style = "text-align: justify;"),
                                 
                                 # Code
                                 h4(tags$b("Data generation code")),
                                 tags$p("generateData <- function(n, seed){", style = "font-family: 'Courier New'"),
                                 tags$p("set.seed(seed)", br(),
                                        "Sodium_gr <- rnorm(n, 3.50, 0.50)", br(),
                                        "Age_years <- Sodium_gr * 18 + rnorm(n)", br(),
                                        "sbp_in_mmHg <- 2.25 * Sodium_gr + 2.00 * Age_years + rnorm(n)", br(),
                                        "Proteinuria_in_mg <- 0.90 * Age_years + 1.80 * sbp_in_mmHg + 3.50 * Sodium_gr + rnorm(n)", br(),
                                        "data.frame(sbp_in_mmHg, Sodium_gr, Age_years, Proteinuria_in_mg)",
                                        style = "font-family: 'Courier New'; padding: 15px"),
                                 
                                 tags$p("}", style = "font-family: 'Courier New'"),
                                 
                                 h4(tags$b("Data display and download")), br(),
                                 p("head(generateData(1000, 777))", style = "font-family: 'Courier New'"),
                                 tableOutput("table_generateData"),
                                 downloadButton(outputId = "download_data", label = tags$b("Download 1.000 simulations (.csv)"))
                                 ),
                          column(6,                             
                                 # Legend
                                 
                                 wellPanel(tags$b("Legend:"), br(),
                                           "AGE = Age (years)", br(),
                                           "SOD = 24-hour dietary sodium intake (g)", br(),
                                           "PRO = 24-hour excretion of urinary protein (proteinuria) (mg)", br(),
                                           "SBP = Systolic blood pressure (mmHg)",
                                           br(), br(),
                                           div(img(src = "graficoC.png", width = "75%"), style = "text-align:center"
                                           )
                                 )
                          )
                                 ),
                 
                 hr()
                 
                 ),
        
        # Tab 3: Collider Visualization -------------------------------
        tabPanel("Collider Visualization",
                 h2(tags$b("Effect of dietary sodium intake on systolic blood pressure for different models' specifications.")), br(),
                 
                 sidebarLayout(
                     sidebarPanel(width = 3,
                                  # Legend
                                  wellPanel(tags$b("Legend:"), br(),
                                            "AGE = Age (years)", br(),
                                            "SOD = 24-hour dietary sodium intake (g)", br(),
                                            "PRO = 24-hour excretion of urinary protein (proteinuria) (mg)", br(),
                                            "SBP = Systolic blood pressure (mmHg)"),
                                  
                                  # Model Selection
                                  h4(tags$b("Select the model(s) to visualize the effect of SOD in SBP:")),
                                  checkboxInput(inputId = "modelA", 
                                                label = div(h6(withMathJax("$$\\text{SBP}=\\beta_{0}+\\beta_{1}\\text{SOD}$$")), style = "margin-top:-10px"),
                                                value = TRUE
                                  ),
                                  
                                  checkboxInput(inputId = "modelB", 
                                                label = div(h6(withMathJax("$$\\text{SBP}=\\beta_{0}+\\beta_{1}\\text{SOD}+\\beta_{2}\\text{AGE}$$")), style = "margin-top:-10px"),
                                                value = TRUE
                                  ),
                                  
                                  checkboxInput(inputId = "modelC", 
                                                label = div(h6(withMathJax("$$\\text{SBP}=\\beta_{0}+\\beta_{1}\\text{SOD}+\\beta_{2}\\text{AGE}+\\beta_{3}\\text{PRO}$$")), style = "margin-top:-10px"),
                                                value = TRUE
                                  ),
                                  
                                  hr(), 
                                  
                                  # Slider for coefficients
                                  h5(withMathJax("Collider Model: $$\\text{PRO}=\\alpha_{0}+\\alpha_{1}\\text{SOD}+\\alpha_{2}\\text{SBP}+ 0.9 \\times \\text{AGE}$$")),
                                  h4(tags$b("Move the input slider to visualize the collider effect")),
                                  
                                  sliderInput(inputId = "beta1", 
                                              label = h5(withMathJax("$$\\alpha_1\\text{(Effect of SOD on PRO)}$$")),
                                              min = 0.5,
                                              max = 5,
                                              step = 0.05,
                                              value = 0.5
                                  ),
                                  
                                  sliderInput(inputId = "beta2", 
                                              label = h5(withMathJax("$$\\alpha_2\\text{(Effect of SBP on PRO)} $$")),
                                              min = 0.5,
                                              max = 5,
                                              step = 0.05,
                                              value = 0.05
                                  )
                     ),
                     
                     # Outputs: panel tabs
                     mainPanel(
                 # No model
                 conditionalPanel(condition = "input.modelA==false && input.modelB==false && input.modelC==false",
                                  h3(tags$b("Please select a model")),
                                  hr()
                                  ),
                 # Models: formula + plot + coefficients
                 fluidRow(column(4, h5(uiOutput("formulaA"))),
                          column(4, h5(uiOutput("formulaB"))),
                          column(4, h5(uiOutput("formulaC")))
                          ),
                 fluidRow(column(4, plotOutput("graph_model_1"), style = 'padding:0px;'),
                          column(4, plotOutput("graph_model_2"), style = 'padding:0px;'),
                          column(4, plotOutput("graph_model_3"), style = 'padding:0px;')
                          ),
                 fluidRow(column(4, h5(uiOutput("coefficient_1"))),
                          column(4, h5(uiOutput("coefficient_2"))),
                          column(4, h5(uiOutput("coefficient_3")))
                 ),
                 hr(),
                 
                 div(h3("Assumed DAG under respective model"), style = "text-align: center"),
                 
                 fluidRow(column(4, conditionalPanel(condition = "input.modelA == true", div(img(src = "graficoA.png", width = "100%"), style = "padding:0px; text-align:center"))),
                          column(4, conditionalPanel(condition = "input.modelB == true", div(img(src = "graficoB.png", width = "80%"), style = "padding:0px; text-align:center"))),
                          column(4, conditionalPanel(condition = "input.modelC == true", div(img(src = "graficoC.png", width = "100%"), style = "padding:0px; text-align:center")))
                 )
                 
        ) #end mainpanel
        
        )
        ),
        
       
        # Tab 4: Article -------------------------------
        tabPanel("Article", br(), br(),
                 uiOutput("article")),

        # Tab 5: Authorship & Acknowledgment -------------------------------
        tabPanel("Credits & Acknowledgment",
                 
                 # Authorship
                 h2(tags$b("Authorship")), br(),
                 fluidRow(column(2, img(src = "logo_MALF.png", width = "100px")),
                          column(10, h4(tags$b("Miguel Angel Luque-Fernandez (PI)")),
                                 h4("Scientific Researcher in Epidemiology and Biostatistics", br(),
                                    "Biomedical Research Institute of Granada", br(),
                                    "Non‐Communicable and Cancer Epidemiology Group (ibs.Granada)", br(),
                                    "University of Granada", br(),
                                    "Assistant Professor of Epidemiology (Honorary)", br(),
                                    "London School of Hygiene & Tropical Medicine, London, UK", br(),                                    
                                    "Visitor Scientist, Department of Epidemiology", br(),  
                                    "Harvard T.H Chan School of Public Health, Boston, MA, USA"),                         
                                 
                                 tags$i(h5("miguel.luque.easp at juntadeandalucia.es"))
                          )
                 ),
                 
                 hr(),
                 
                 fluidRow(column(2, img(src = "logo_DRS.png", width = "100px")),
                          column(10, h4(tags$b("Daniel Redondo Sánchez")),
                                 h4("Research Assistant", br(),
                                    "Biomedical Research Institute of Granada", br(),
                                    "Non‐Communicable and Cancer Epidemiology Group (ibs.Granada)", br(),
                                    "University of Granada", br(),
                                    "Andalusian School of Public Health"),
                                 
                                 tags$i(h5("daniel.redondo.easp at juntadeandalucia.es"))
                          )
                 ),
                 
                 hr(),
                 
                 fluidRow(column(2, img(src = "logo_MS.png", width = "100px")),
                          column(10, h4(tags$b("Michael Schomaker")),
                                 h4("Senior Statistician IeDEA HIV-Cohort", br(),
                                    "School of Public Health and Family Medicine", br(),
                                    "Center for Infectious Disease Epidemiology and Research", br(),
                                    "University of Cape Town, Cape Town, South Africa"),
                                 
                                 tags$i(h5("michael.schomaker at uct.ac.za"))
                          )
                 ),
                 
                 hr(),
                 
                 fluidRow(column(2, img(src = "logo_MJSP.jpg", width = "100px")),
                          column(10, h4(tags$b("Maria Jose Sánchez Perez")),
                                 h4("Subdirector Biomedical Research Institute of Granada", br(),
                                    "Director Non‐Communicable and Cancer Epidemiology Group (ibs.Granada)", br(),
                                    "University of Granada", br(),
                                    "Director of the Granada Cancer Registry", br(),
                                    "CIBER of Epidemiology and Public Health (CIBERESP)", br(),
                                    "Andalusian School of Public Health"),
                                 
                                 tags$i(h5("mariajose.sanchez.easp at juntadeandalucia.es"))
                          )
                 ),
                 
                 hr(),
                 
                 fluidRow(column(2, img(src = "Anand.jpg", width = "100px")),
                          column(10, h4(tags$b("Anand Vaidya")),
                                 h4("Assistant Professor of Medicine", br(),
                                    "Harvard Medical School, Harvard University", br(),
                                    "Director of the Center for Adrenal Disorders (Diabetes, Hypertension)", br(),
                                    "Brigham and Women's Hospital (Endocrinology), Boston, MA, USA"),
                                
                                  tags$i(h5("anandvaidya at bwh.harvard.edu"))
                          )
                 ),
                 
                 hr(),
                 
                 fluidRow(column(2, img(src = "MSchnitzer.png", width = "100px")),
                          column(10, h4(tags$b("Mireille E. Schnitzer")),
                                 h4("Assistant Professor of Biostatistics", br(),
                                    "Faculty of Pharmacy", br(),
                                    "University of Montreal, Montreal, Canada", br(),
                                    "Adjunt Professor of Biostatistics", br(),
                                    "Department Epidemiology, Biostatistics and Occupational Health", br(),
                                    "McGill University, Montreal, Canada"),
                                 
                                 tags$i(h5("mireille.schnitzer at umontreal.ca"))
                          )
                 ),

                 hr(),
                 # Acknowledgment
                 h2(tags$b("Acknowledgment")),
                 tags$b("Funding information"), br(),
                 "Carlos III Institute of Health, Grant/Award Number: CP17/00206 and the Andalusian Department of Health, Grant Number: PI-0152/2017.", br(), br(),
                 fluidRow(column(5, img(src = "logofeder.png", width = "75%")),
                          column(5, img(src = "logoibs.png", width = "75%"))
                          )
                 )
                  
        ) # End tabsetpanel
) # End UI

# Server function -------------------------------
server <- function(input, output) {

    # Formulae
    output$formulaA <- renderUI({
        if(input$modelA == TRUE) {
         withMathJax("$$\\text{Model 1: SBP} = \\beta_{0} + \\beta_{1} \\text{SOD}$$
                      $$\\text{(Unadjusted model)}$$") 
        }
    })
    
    output$formulaB <- renderUI({
        if(input$modelB == TRUE) {
            withMathJax("$$\\text{Model 2: SBP} = \\beta_{0} + \\beta_{1} \\text{SOD} + \\beta_{2} \\text{AGE}$$
                         $$\\text{(Adjusted model for age)}$$") 
        }  
    })
    
    output$formulaC <- renderUI({
        if(input$modelC == TRUE) {
            withMathJax("$$\\text{Model 3: SBP} = \\beta_{0} + \\beta_{1} \\text{SOD} + \\beta_{2} \\text{AGE} + \\beta_{3} \\text{PRO}$$
                         $$\\text{(Adjusted model for age including the collider)}$$") 
        }
    })
    
    # Simulated data
    ObsData <- reactive({set.seed(777)
                         generateData(input$beta1, input$beta2, n = 1000)})
    
    # Head from simulated data 
    output$table_generateData <- renderTable(head(ObsData())) #%>% rename("Systolic blood pressure (mmHg)" = "sbp", "Age (years)" = "age",
                                                                        #"24-hour dietary sodium intake (g)" = "sodium",
                                                                        #"24-hour excretion of urinary protein (proteinuria) (mg)" = "proteinuria"))
    
    # Linear models fits + graphs
    fit1 <- reactive({lm(sbp ~ sodium, data = ObsData())})
    fit2 <- reactive({lm(sbp ~ sodium + age, data = ObsData())})
    fit3 <- reactive({lm(sbp ~ sodium + age + proteinuria, data = ObsData())})
    
    grafico1 <- reactive({visreg(fit1(), points = list(cex = 1.5, pch = 1), jitter = 10, bty = "n")})
    grafico2 <- reactive({visreg(fit2(), points = list(cex = 1.5, pch = 1), jitter = 10, bty = "n")})
    grafico3 <- reactive({visreg(fit3(), points = list(cex = 1.5, pch = 1), jitter = 10, bty = "n")})
    
    
    # Figures
    alpha_points <- 0.4
    color_points <- "black"
    
    output$graph_model_1<-renderPlot({
      if(input$modelA == TRUE) plot(grafico1(), gg = TRUE, ylab = "SBP (mmHg)", xlab = "Sodium (gr)",
                                  points = list(size = 2, pch = 1, alpha = alpha_points, col = color_points),
                                  line = list(col = "blue", size = 1.3)) +
                                  theme_classic() +
                                  theme(axis.text = element_text(size = 15), axis.text.y = element_text(face = "bold"), axis.title = element_text(size = 17))
        
    })
    
    output$graph_model_2<-renderPlot({
      if(input$modelB == TRUE) plot(grafico2()[[1]], gg = TRUE, ylab=  "SBP (mmHg)", xlab="Sodium (gr)",
                                  points = list(size = 2, pch = 1, alpha = alpha_points, col = color_points),
                                  line = list(col = "blue", size = 1.3)) +
                                  theme_classic() + 
                                  theme(axis.text = element_text(size = 15), axis.text.y = element_text(face = "bold"), axis.title = element_text(size = 17))
    })
    
    # Positive slope -> blue; negative -> red
    output$graph_model_3<-renderPlot({
            if(input$modelC == TRUE)
              if(fit3()$coefficients["sodium"] > 0) plot(grafico3()[[1]], gg = TRUE, ylab = "SBP (mmHg)", xlab = "Sodium (gr)",
                                                    points = list(size = 2, pch = 1, alpha = alpha_points, col = color_points),
                                                    line = list(col = "blue", size = 1.3)) +
                                                    theme_classic() + 
                                                    theme(axis.text = element_text(size = 15), axis.text.y = element_text(face = "bold"), axis.title = element_text(size = 17))
              else 
                plot(grafico3()[[1]], gg = TRUE, ylab = "SBP (mmHg)", xlab = "Sodium (gr)",
                     points = list(size = 2, pch = 1, alpha = alpha_points, col = color_points),
                     line = list(col = "red", size = 1.3)) +
                     theme_classic() + 
                     theme(axis.text = element_text(size = 15), axis.text.y = element_text(face = "bold"), axis.title = element_text(size = 17))
    })
    
    
    #axis.title.x = element_text(size=16), axis.text.x = element_text(size=16),axis.title.y = element_text(size=16, angle = 90), axis.text.y = element_text(size=16), legend.text =  element_text(size=13), legend.title =  element_text(size=13, face = "bold", hjust = 0.5),legend.position =   "bottom", legend.key.width = unit(1.75, "cm"))

    # Coefficients
    output$coefficient_1<-renderUI({
        if(input$modelA == TRUE)  withMathJax(sprintf("$$ \\beta_{1} = %.03f$$", fit1()$coefficients["sodium"]))
    })
    
    output$coefficient_2<-renderUI({
      if(input$modelB == TRUE)  withMathJax(sprintf("$$ \\beta_{1} = %.03f$$", fit2()$coefficients["sodium"]))
    })
    
    output$coefficient_3<-renderUI({
      if(input$modelC == TRUE)  withMathJax(sprintf("$$ \\beta_{1} = %.03f$$", fit3()$coefficients["sodium"]))
    })
    
    # Download data
    output$download_data <- downloadHandler(
              filename = "data.csv",
              content = function(file) { 
              write.csv(ObsData(), file) 
              }
    )
    
    # Article PDF
    output$article <- renderUI({
        tags$iframe(style = "height : 700px; width : 100%", src = "Manuscript.pdf")
    })

}

# Building the shiny application
shinyApp(ui = ui, server = server)
