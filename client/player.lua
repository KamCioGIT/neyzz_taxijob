RegisterCommand(Config.taxiCommand, function (source, args, raw)
    lib.callback.await('neyzz_taxi:callTaxi')
end)