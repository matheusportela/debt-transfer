module DebtTransferHelper
    def format_debt debt
        if debt == Float::INFINITY
            'Insolvente'
        else
            number_to_currency(debt, unit: "R$", separator: ",",
                delimitier: ".")
        end
    end
end
