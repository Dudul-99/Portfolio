#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(tidyverse)
library(shinyWidgets)
library(dlookr)
library(janitor)
library(gt)
library(gtsummary)
library(flextable)
library(readr)
library(stringi)
library(stringr)
library(plotly)
library(lubridate)
library(readxl)
library(shinydashboard)
library(highcharter)

#chargement des données
setwd('/Users/abdul/Desktop/R_data_science')
Achats <- read_csv("Achats.csv", col_types = cols(...1 = col_skip(), 
                                                  Date_de_commande = col_date(format = "%Y-%m-%d"), 
                                                  `Date_d'expédition` = col_date(format = "%Y-%m-%d")))




# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title="Tableau de bord des supermarchés",titleWidth = "25%"),
  dashboardSidebar(sidebarMenu(
    menuItem("Résumé", tabName = "synthese", icon = icon("house")),
    menuItem("Clients", tabName = "client", icon = icon("users")),
    menuItem("Produits commandés", tabName = "produit_commende", icon = icon("boxes-stacked")),
    menuItem("Mode de livraison", tabName = "mode_livraison", icon = icon("truck-fast"))
  )),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "synthese",
              fluidRow(
                box(title=strong("Revenu annuel"),solidHeader = TRUE,
                    selectInput("annee", "Choisissez une année", choices = sort(unique(year(Achats$Date_de_commande)))),
                    verbatimTextOutput("revenuID")),
                box(title = strong("Revenu mensuel"),solidHeader = TRUE,
                    selectInput("annee2", "Choisissez une année", choices = sort(unique(year(Achats$Date_de_commande)))),
                    verbatimTextOutput("revenu_menseulleID")),
                box(title = strong("Profit annuel"),solidHeader = TRUE,
                    selectInput("annee3", "Choisissez une année", choices = sort(unique(year(Achats$Date_de_commande)))),
                    verbatimTextOutput("profitID")),
                box(title=strong("Profit mensuel"),solidHeader = TRUE,
                    selectInput("annee4", "Choisissez une année", choices = sort(unique(year(Achats$Date_de_commande)))),
                    verbatimTextOutput("prfit_mensuelleID")),
                box(title=strong("Revenu par pays"),solidHeader = TRUE,
                    plotlyOutput("carte")),
                
                box(title = strong("Distribution mensuelle du revenu"),
                    selectizeInput(
                      inputId = "annee5",
                      label = "Sélectionnez les années",
                      choices = sort(unique(year(Achats$Date_de_commande))),
                      selected='2020',
                      multiple = TRUE
                    ),
                    plotlyOutput("lineplot"))
              )
      ),
      
      tabItem(
        tabName = "client",
        fluidRow(
          box(title = strong("TOP 10 des clients"),solidHeader = TRUE,
              plotlyOutput("bar_clients")),
          box(title=strong("Distribution mensuelle selon la catégorie du client"),solidHeader = TRUE,
              selectInput("annee6","Choisissez une année",choices=sort(unique(year(Achats$Date_de_commande)))),
              plotlyOutput("month_evolution")),
          box(title = strong("Répartition des clients par type de produit acheté"),solidHeader = TRUE,
              plotlyOutput("bar_client_cat"))
        )
      ),
      
      
      tabItem(
        tabName = "produit_commende",
        fluidRow(
          box(title = strong("Répartition du revenu en fonction du type de produits vendus (%)"),solidHeader = TRUE,
              highchartOutput("sunburst")),
          box(title = strong("Top 10 des produits en fonction du revenu généré"),solidHeader = TRUE,
              plotlyOutput("bar_produit")),
          box(title = strong("Répartition du profit en fonction du type de produits vendus (%)"),solidHeader = TRUE,
              highchartOutput("treemap"))
        )
      ),
      
      tabItem(
        tabName="mode_livraison",
        fluidRow(
          box(title = strong("Revenu par mode d'expédition"),solidHeader = TRUE,
              plotlyOutput("piechart")),
          box(title = strong("Distribution de la durée en fonction du mode d'expédition"),solidHeader = TRUE,
              plotlyOutput("boxplot"))
        )
      )
      
      
      
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Onglet Résumé
  output$revenuID <- renderText({
    annee_selectionnee <- as.integer(input$annee)
    revenu_annuel <- sum(Achats$Ventes[year(Achats$Date_de_commande) == annee_selectionnee])
    annee_precedente <- annee_selectionnee - 1
    revenu_annee_precedente <- sum(Achats$Ventes[year(Achats$Date_de_commande) == annee_precedente])
    
    formatted_revenu <- paste("€", format(round(revenu_annuel, 0), big.mark = ","))
    
    if (annee_precedente %in% unique(year(Achats$Date_de_commande))) {
      pourcentage_evolution <- ((revenu_annuel - revenu_annee_precedente) / revenu_annee_precedente) * 100
      formatted_evolution <- paste("Évolution par rapport à l'année précédente:", format(round(pourcentage_evolution, 2), nsmall = 2), "%")
    } else {
      formatted_evolution <- "Année précédente non disponible"
    }
    
    return(paste("Revenu pour l'année", annee_selectionnee, ":", formatted_revenu,"\n",formatted_evolution))
  })
  
  
  output$revenu_menseulleID <- renderText({
    annee_selectionnee <- as.integer(input$annee2)
    revenu_menseulle<- sum(Achats$Ventes[year(Achats$Date_de_commande)==annee_selectionnee])/12
    annee_precedente<-annee_selectionnee - 1
    revenu_mensuelle_precedente<-sum(Achats$Ventes[year(Achats$Date_de_commande)==annee_precedente])/12
    
    formatted_revenu<-paste("€",format(round(revenu_menseulle,0),big.mark=","))
    
    if (annee_precedente %in% unique(year(Achats$Date_de_commande))){
      pourcentage_evolution<-((revenu_menseulle-revenu_mensuelle_precedente)/revenu_mensuelle_precedente)*100
      formatted_evolution <- paste("Évolution par rapport à l'année précédente:", format(round(pourcentage_evolution, 2), nsmall = 2), "%")
    } else {
      formatted_evolution<-"Année précedente non disponible"
    }
    return(paste("Revenu mensuel pour l'année",annee_selectionnee,":",formatted_revenu,"\n",formatted_evolution))
  })
  
  output$profitID<-renderText({
    annee_selectionnee <- as.integer(input$annee3)
    profit_annuel <- sum(Achats$Profit[year(Achats$Date_de_commande) == annee_selectionnee])
    annee_precedente <- annee_selectionnee - 1
    profit_annee_precedente <- sum(Achats$Profit[year(Achats$Date_de_commande) == annee_precedente])
    
    formatted_revenu <- paste("€", format(round(profit_annuel, 0), big.mark = ","))
    
    if (annee_precedente %in% unique(year(Achats$Date_de_commande))) {
      pourcentage_evolution <- ((profit_annuel - profit_annee_precedente) / profit_annee_precedente) * 100
      formatted_evolution <- paste("Évolution par rapport à l'année précédente:", format(round(pourcentage_evolution, 2), nsmall = 2), "%")
    } else {
      formatted_evolution <- "Année précédente non disponible"
    }
    
    return(paste("Profit pour l'année", annee_selectionnee, ":", formatted_revenu,"\n",formatted_evolution))
    
  })
  
  
  
  output$prfit_mensuelleID<-renderText({
    
    annee_selectionnee <- as.integer(input$annee4)
    profit_mensuel <- sum(Achats$Profit[year(Achats$Date_de_commande) == annee_selectionnee])/12
    annee_precedente <- annee_selectionnee - 1
    profit_annee_precedente <- sum(Achats$Profit[year(Achats$Date_de_commande) == annee_precedente])/12
    
    formatted_revenu <- paste("€", format(round(profit_mensuel, 0), big.mark = ","))
    
    if (annee_precedente %in% unique(year(Achats$Date_de_commande))) {
      pourcentage_evolution <- ((profit_mensuel - profit_annee_precedente) / profit_annee_precedente) * 100
      formatted_evolution <- paste("Évolution par rapport à l'année précédente:", format(round(pourcentage_evolution, 2), nsmall = 2), "%")
    } else {
      formatted_evolution <- "Année précédente non disponible"
    }
    
    return(paste("Profit pour menseulle de l'année", annee_selectionnee, ":", formatted_revenu,"\n",formatted_evolution))
  })
  
  output$carte <- renderPlotly({
    # Regroupez par "Pays_englais" pour obtenir le total par pays
    Achats_grouped <- Achats %>%
      group_by(Pays_englais) %>%
      summarize(Revenu = sum(Ventes))
    
    # Créez une carte choroplèthe
    map_plot <- plot_ly(data = Achats_grouped, type = 'choropleth',
                        locations = ~Pays_englais,
                        z = ~Revenu,
                        locationmode = 'country names',
                        colorscale = 'Viridis',
                        text = ~paste(Pays_englais)) %>%
      colorbar(title = "Revenu")
    
    # Personnalisez la mise en page
    map_plot <- map_plot %>% layout(
      
      geo = list(
        scope = 'europe',  # Vous pouvez ajuster la portée selon votre préférence
        showframe = FALSE,
        projection = list(type = 'mercator')
      )
    )
    
    # Affichez la carte
    map_plot
  })
  
  
  output$lineplot <- renderPlotly({
    # Filtrer les données en fonction des années sélectionnées
    selected_years <- input$annee5
    Achats_filtered <- Achats %>%
      filter(year(Date_de_commande) %in% selected_years)
    
    # Créer le graphique avec superposition des courbes
    Achats_grouped <- Achats_filtered %>%
      group_by(year(Date_de_commande), month(Date_de_commande)) %>%
      summarize(Total_Ventes = sum(Ventes))
    
    Achats_grouped$Month <- month(Achats_grouped$`month(Date_de_commande)`, label = TRUE, locale = "fr_FR")
    
    plot_ly(data = Achats_grouped, x = ~`month(Date_de_commande)`, y = ~Total_Ventes, type = 'scatter', mode = 'lines+markers', split = ~`year(Date_de_commande)`) %>%
      layout(
        xaxis = list(
          title = "Mois",
          tickvals = 1:12,
          ticktext = unique(Achats_grouped$Month)
        ),
        yaxis = list(title = "Revenu"),
        title = "Évolution des revenus au cours de l'année"
      )
  })
  
  
  
  # Onglet Clients
  
  output$bar_clients<-renderPlotly({
    tempo<-Achats %>% 
      group_by(Nom_du_client) %>% 
      summarise(total_achat=round(sum(Ventes))) %>% 
      arrange(desc(total_achat)) %>% 
      top_n(10)
    
    plot_ly(data = tempo, x = ~total_achat, y = ~reorder(Nom_du_client, total_achat), type = "bar", orientation = 'h',
            hoverinfo = 'text', text = ~paste('€', format(total_achat, big.mark = ",")), 
            marker = list(colors = 'blue')) %>%
      layout(title = "Top 10 des clients", yaxis = list(title = "Nom des clients"),
             xaxis=list(title="Revenue"))
    
  })
  
  
  output$month_evolution<-renderPlotly({
    selected_years <- input$annee6
    Achats_filtered <- Achats %>%
      filter(year(Date_de_commande) %in% selected_years)
    
    
    tempo <- Achats_filtered %>%
      group_by(Month = month(Date_de_commande), Segment) %>%
      summarise(Revenue = round(sum(Ventes, na.rm = TRUE))) %>%
      as.data.frame()
    # Traduisez les noms des mois en français
    tempo$Month <- month(tempo$Month, label = TRUE, locale = "fr_FR")
    
    pbyRevAct <- plot_ly(
      data = tempo,
      x = ~Month,
      y = ~Revenue,
      color = ~Segment,
      type = 'scatter',
      mode = 'lines'
    )
    
    pbyRevAct <- pbyRevAct %>% layout(
      yaxis = list(title = "Revenue"),
      xaxis = list(title = "Mois"),
      legend = list(orientation = 'h', x = 0.1, y = 1.2)
    )
    
    pbyRevAct
  })
  
  
  
  output$bar_client_cat<-renderPlotly({
    
    # Obtenez d'abord le top 10 des clients en termes de ventes
    top_10_clients <- Achats %>%
      group_by(Nom_du_client) %>%
      summarise(total_ventes = round(sum(Ventes))) %>%
      top_n(10, wt = total_ventes)
    
    # Ensuite, filtrez les données originales pour inclure uniquement ces 10 clients
    filtered_data <- Achats %>%
      filter(Nom_du_client %in% top_10_clients$Nom_du_client)
    
    # Maintenant, agrégez par Catégorie pour ces 10 clients
    test <- filtered_data %>%
      group_by(Nom_du_client, Catégorie) %>%
      summarise(total_achat = round(sum(Ventes))) %>%
      arrange(desc(total_achat))
    
    # Créez un graphique en barres empilées avec Plotly
    plot_ly(data = test, x = ~reorder(Nom_du_client, -total_achat), y = ~total_achat, type = 'bar', marker = list(line = list(width = 2)), text = ~paste(Catégorie, ": ", total_achat), color = ~Catégorie) %>%
      layout(title = "Répartition par Catégories",
             xaxis = list(title = "Client"),
             yaxis = list(title = "Revenu"),
             barmode = 'stack') %>%
      config(displayModeBar = FALSE)
  })
  
  
  
  # Onglet Produits commandés
  
  output$sunburst<-renderHighchart({
    t <- Achats %>%
      group_by(Catégorie, `Sous-catégorie`) %>%
      summarize(Percentage = sum(Ventes) / sum(Achats$Ventes) * 100) %>%
      mutate(Percentage = round(Percentage, 0)) %>% 
      arrange(Catégorie,`Sous-catégorie`)
    
    # Créez le graphique sunburst
    dout <- data_to_hierarchical(t, c("Catégorie", "Sous-catégorie"), "Percentage")
    
    # Créez le graphique sunburst avec des étiquettes de pourcentage
    hchart(dout, type = "sunburst") %>%
      hc_labels(
        list(
          enabled = TRUE,
          format = "{point.name}: {point.value}%",
          style = list(fontSize = "12px")
        )
      )
  })
  
  
  output$bar_produit<-renderPlotly({
    test<-Achats %>% 
      group_by(Nom_du_produit) %>% 
      summarise(total_achat=round(sum(Ventes))) %>% 
      arrange(desc(total_achat)) %>% 
      top_n(10)
    plot_ly(data = test, x = ~total_achat, y = ~reorder(Nom_du_produit,total_achat), type = "bar", orientation = 'h',
            hoverinfo='text',text=~paste('€', format(total_achat,big.mark=",")) ,marker = list(colors = 'blue')) %>%
      layout(
        xaxis = list(title = "Revenue"),
        yaxis = list(title = "Nom du produits"))
  })
  
  
  output$treemap<-renderHighchart({
    t <- Achats %>%
      group_by(Catégorie, `Sous-catégorie`) %>%
      summarize(Percentage = sum(Profit) / sum(Achats$Profit) * 100) %>%
      mutate(Percentage = round(Percentage, 0)) %>% 
      arrange(Catégorie,`Sous-catégorie`)
    
    # Créez le graphique sunburst
    dout <- data_to_hierarchical(t, c("Catégorie", "Sous-catégorie"), "Percentage")
    
    # Créez le graphique sunburst avec des étiquettes de pourcentage
    hchart(dout, type = "treemap") %>%
      hc_labels(
        list(
          enabled = TRUE,
          format = "{point.name}: {point.value}%",
          style = list(fontSize = "12px")
        )
      )
  })
  
  
  # Onglet Mode de livraison
  
  output$piechart<-renderPlotly({
    plot_ly(data = Achats, labels = ~`Mode_d'expédition`, values = ~1, type = 'pie', hole = 0.4,
            textinfo = "label+percent",showlegend = FALSE)
  })
  
  
  
  
  output$boxplot<-renderPlotly({
    tempo<-Achats %>%
      mutate(temps_exp = as.numeric(abs(difftime(`Date_d'expédition`, Date_de_commande, units = "days")))) %>%
      arrange(desc(temps_exp))%>% 
      filter(temps_exp<10)
    
    
    plot_ly(tempo, x = ~`Mode_d'expédition`, y = ~temps_exp, type = "box") %>%
      layout(
        xaxis = list(title = "Mode d'expédition"),
        yaxis = list(title = "Jours "))
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

