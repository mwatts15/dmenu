require 'open3'

class String
    def initialize
        super
        force_encoding("utf-8")
    end
    def kanji_off
        # Gives me the number of spaces "missing" with double-width
        # kanji characters. Used for formatting adjustment
        (self.bytes.count - self.length) / 2
    end
    alias :| alignr
end
module Dmenu
    def dmenu (entries, prompt='select an item', height=false,
                  width=1366,
                  fg_color='"#FFFFFF"',
                  bg_color='"#000000"',
                  sel_fg_color='"#555555"',
                  sel_bg_color='"#eeeeee"',
                  font='"Sazanami Mincho":pixelsize=14',
                  line_height=nil)
        if !height
            height=entries.count
        end
        md = font.to_s.match(":pixelsize=(\d+)")
        if md.nil?
            font_width = 14 #in pixels
        else
            font_width = md[1]
        end
        res = ""

        entries.collect! do |line|
            l, r = line.split("|||")
            r ? alignr(lhs, r.scrunch(width / font_width), width) : l
        end
        cmdline = "dmenu -f -p \"#{prompt}\" -nf #{fg_color} \
        -nb #{bg_color} \
        -sb #{sel_bg_color} \
        -sf #{sel_fg_color} \
        -i -l #{height} \
        -w #{width} \
        -fn #{font} " + (if line_height.nil? then "" else "-lh " + line_height.to_s end)

        err_messages = nil
        Open3.popen3(cmdline) do |i, o, e, t|
            i.print(entries.join("\n"))
            i.close
            err_messages = e.read
            res = o.gets
        end
        stat = $?
        if stat != 0
            if err_messages.include?("Error")
                raise Exception.new("Couldn't print list: #{stat}\n#{err_messages}")
            end
        end
        res.to_s.chomp
    end
    def alignr(lhs, r, w)
        str = lhs + r.rjust(w - lhs.width, '.')
        str
    end
    def scrunch(str, size, dots='...')
        if str.length < size
            str
        else
            middle = self.length / 2
            # Not centered; intentional
            lhs = str[0..middle]
            rhs = str[-middle..-1]
            while str.width > size
                str = lhs + dots + rhs
                lhs = lhs[0..-2]
                rhs = rhs[1..-1]
            end
            str
        end
    end
end
