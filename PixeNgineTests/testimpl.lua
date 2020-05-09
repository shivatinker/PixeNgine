local module = {}

function module.test(x, y)
    local a, m = test.addmul(x, y)
    print(a, m)
    return a, m
end

return module
