--[[
Copyright (c) 2014 Google Inc.
See LICENSE file for full terms of limited license.
]]

require 'convnet'

return function(args)
    args.n_units        = {8,16,32}
    args.filter_size    = {3, 3, 3}
    args.filter_stride  = {1, 1, 1}
    args.n_hid          = {64}
    args.nl             = nn.Rectifier

    return create_network(args)
end
