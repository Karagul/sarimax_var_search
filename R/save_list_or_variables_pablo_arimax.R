
# final variabels used in stata  arimax prediction  code used by pablo
final_stata_variables <- list(
  Argentina = c("act_chn",
                "act_eco_bra",
                "autos",
                "emae",
                "imp",
                "imp_capital",
                "ip",
                "ip_bra",
                "ip_ue",
                "vta_mall",
                "cap",
                "cemento",
                "icc_nacional",
                "imp_consumer",
                "ip_us",
                "construction",
                "cred",
                "exp",
                "expectativa_inflacion",
                "icc_capital",
                "imp_intermediate"),
  
  Bolivia = c("cred",
              "exp",
              "igae",
              "gto_total",
              "hidrocarburo",
              "imp_capital",
              "act_chn",
              "exp_hydrocarbon",
              "imp",
              "ip_ue",
              "ip_us"),
  
  Brasil = c("act_chn",
             "conf_ibre",
             "cred",
             "ibc",
             "imp_consumer",
             "ip_capital_goods",
             "ip_mining",
             "ip_us",
             "vta_bs_k",
             "imp",
             "imp_intermediate",
             "conf_cons",
             "conf_emp",
             "ip",
             "ip_consumer_goods",
             "ip_intermediate_goods",
             "ip_manufacturing",
             "retail",
             "tax",
             "tcr",
             "tot"),
  
  Chile = c("act_chn",
            "cred",
            "electricity",
            "imp",
            "ip_us",
            "m1",
            "m2",
            "vta_auto",
            "vtas_superm",
            "copper_output",
            "exp",
            "exp_mining",
            "imacec",
            "imce",
            "imp_capital",
            "imp_consumer",
            "imp_intermediate",
            "ip_ine",
            "ipec",
            "tcn",
            "tcr",
            "tot"),
  
  Colombia = c("imp_intermediate",
               "retail",
               "ip",
               "ip_sales",
               "m1",
               "m2",
               "cred",
               "ip_us",
               "ise",
               "tot"),
  
  Ecuador = c("oil_production",
              "cred",
              "imp",
              "imp_int",
              "imp_k",
              "ing_gob",
              "ip_us",
              "oil_export_barril",
              "exp",
              "gto_gob_k",
              "ideac",
              "imp_cons",
              "recaud_iva",
              "tot"),
  
  Paraguay = c("act_chn",
               "cred",
               "imaep",
               "imp_cap",
               "ip",
               "ip_bra",
               "ip_ue",
               "m2",
               "tcr",
               "exp_combus",
               "exp_manuf_ind",
               "imp_con",
               "mat_cons",
               "remesa",
               "act_eco_bra",
               "exp",
               "exp_manuf_agro",
               "exp_prim",
               "imp",
               "retail",
               "vtas_super"),
  
  Peru = c("imp_intermediate",
           "imp_capital",
           "pib_manu",
           "exp",
           "imp_consumer",
           "pib",
           "pib_nonprimary",
           "pib_primary",
           "tot"),
  
  Uruguay = c("emae_arg",
              "ip_us",
              "m1",
              "act_chn",
              "act_eco_bra",
              "imp_intermediate",
              "ip_bra",
              "ipc",
              "imp",
              "imp_capital",
              "ip",
              "ip_sinancap",
              "ip_ue")
)


saveRDS(final_stata_variables, file = "./data/final_stata_variables.rds")
