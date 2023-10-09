# Internal method for load a CSV file 
function _loadcsvfile(path::String)::DataFrame
    return CSV.read(path, DataFrame);
end

function _jld2(path::String)::Dict{String,Any}
    return load(path);
end

# Load harded coded specific files -
function MyTreasuryBillDataSet()::DataFrame
    return _loadcsvfile(joinpath(_PATH_TO_DATA, "US-TBill-Prices-TD-May-Sept-2023.csv"));
end

function MyTreasuryNotesAndBondsDataSet()::DataFrame
    return _loadcsvfile(joinpath(_PATH_TO_DATA, "US-TNotesBonds-Prices-TD-May-Sept-2023.csv"));
end

function MyDailyTreasuryYieldCurveDataSet(;year::String = "2023")::DataFrame


    if (year == "2021")
        return _loadcsvfile(joinpath(_PATH_TO_DATA, "daily-treasury-rates-2021.csv"));
    elseif (year == "2022")
        return _loadcsvfile(joinpath(_PATH_TO_DATA, "daily-treasury-rates-2022.csv"));
    end

    # default to 2023 -
    return _loadcsvfile(joinpath(_PATH_TO_DATA, "daily-treasury-rates-2023.csv"));
end

MyPortfolioDataSet() = _jld2(joinpath(_PATH_TO_DATA, "OHLC-Daily-SP500-5-years-TD-1256.jld2"));
MyFirmMappingDataSet() = _loadcsvfile(joinpath(_PATH_TO_DATA, "SP500-Firm-Mapping-06-22-23.csv"));
MyOptionsChainDataSet() = _loadcsvfile(joinpath(_PATH_TO_DATA, "AMD-options-exp-2023-08-18-monthly-07-18-2023.csv"));