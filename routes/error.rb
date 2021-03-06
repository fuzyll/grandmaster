##
# Grandmaster | StarCraft 2 Ladder (Error Routes)
#
# Copyright (c) 2014 Alexander Taylor <ajtaylor@fuzyll.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
##

module Grandmaster
    class Application < Sinatra::Base
        # default error
        error do
            @error = request.env["sinatra.error"]
            slim :error
        end

        # 401 (not authorized)
        error 401 do
            @error = "Not Authorized"
            slim :error
        end

        # 403 (forbidden)
        error 403 do
            @error = "Forbidden"
            slim :error
        end

        # 404 (not found)
        error 404 do
            @error = "Not Found"
            slim :error
        end

        # 501 (not implemented)
        error 501 do
            @error = "Not Implemented"
            slim :error
        end
    end
end
