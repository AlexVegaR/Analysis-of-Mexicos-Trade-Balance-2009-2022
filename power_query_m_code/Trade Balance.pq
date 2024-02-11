// This query creates the "Trade Balance" dataset
let
    // Getting data from the Excel file "trade-balance.xlsx"
    Source = Excel.Workbook(
        File.Contents("D:\Documents\Portfolio\Mexico's Trade Balance\dataset\trade_balance.xlsx"), null, false
    ){
        [Item = "value", Kind = "Sheet"]
    }[Data],
    // Removing the top 4 rows with null values
    #"Removed Top Rows" = Table.Skip(Source, 4),
    // Promoting the headers
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars = true]),
    // Removing unnecessary columns for the analysis
    #"Removed Columns" = Table.RemoveColumns(
        #"Promoted Headers",
        {"cve_entity", "desc_entity", "cve_municipality", "desc_municipality", "id_indicator", "measurement_unit"}
    ),
    // Unpivoting the columns containing the date and value of the operations
    #"Unpivoted Columns" = Table.UnpivotOtherColumns(#"Removed Columns", {"indicator"}, "Date", "Value"),
    // Splitting the "Date" column into "Year" and "month_" columns
    #"Split Column" = Table.SplitColumn(
        #"Unpivoted Columns", "Date", Splitter.SplitTextByDelimiter("/", QuoteStyle.Csv), {"Year", "month_"}
    ),
    // Adding the "Month" column by replacing the values of "month_"
    #"Added Month" = Table.AddColumn(
        #"Split Column",
        "Month",
        each
            if [month_] = "m01" then
                "January"
            else if [month_] = "m02" then
                "February"
            else if [month_] = "m03" then
                "March"
            else if [month_] = "m04" then
                "April"
            else if [month_] = "m05" then
                "May"
            else if [month_] = "m06" then
                "June"
            else if [month_] = "m07" then
                "July"
            else if [month_] = "m08" then
                "August"
            else if [month_] = "m09" then
                "September"
            else if [month_] = "m10" then
                "October"
            else if [month_] = "m11" then
                "November"
            else if [month_] = "m12" then
                "December"
            else
                null,
        type text
    ),
    // Splitting the "indicator" column into "Trade", "Category", "Product", "indicator.1" and "indicator.2" columns
    #"Split Column1" = Table.SplitColumn(
        #"Added Month",
        "indicator",
        Splitter.SplitTextByDelimiter(". ", QuoteStyle.Csv),
        {"indicator.1", "Trade", "Category", "Product", "indicator.2"}
    ),
    // Removing the "indicator.1", "indicator.2" and "month_" columns
    #"Removed Columns1" = Table.RemoveColumns(#"Split Column1", {"indicator.1", "indicator.2", "month_"}),
    // Changing the "Value" and "Year" columns to their proper data type
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Columns1", {{"Value", type number}, {"Year", Int64.Type}}),
    // Multiplying the "Value" column by 1,000,000
    #"Multiplied Column" = Table.TransformColumns(#"Changed Type", {{"Value", each _ * 1000000, type number}})
in
    #"Multiplied Column"
