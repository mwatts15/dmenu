require 'open3'

class String
    def initialize
        super
        force_encoding("utf-8")
    end
end
module Dmenu
    require 'wcwidth'
    def self.dmenu (entries, prompt='select an item', height=false,
                  width=1366,
                  fg_color='#FFFFFF',
                  bg_color='#000000',
                  sel_fg_color='#555555',
                  sel_bg_color='#eeeeee',
                  font='Sazanami Mincho:pixelsize=14',
                  line_height=nil)
        if !height
            height=entries.count
        end
        md = font.to_s.match('.*:pixelsize=(\d+).*')
        if md.nil?
            font_width = 14 #in pixels
        else
            font_width = md[1].to_i
        end

        res = ""
        lr_separation = 4
        textwidth = 2 * width / font_width - lr_separation
        puts(textwidth)
        entries.collect! do |line|
            l, r = line.split("|||")
            scrunched = scrunch(r, [textwidth - l.width - lr_separation, textwidth / 2].max)
            s = r ? alignr(l, scrunched, textwidth) : l
            puts("w=#{s.width}, l=#{s.length}")
            s
        end
        cmdline = "dmenu -f -p \"#{prompt}\" -nf \"#{fg_color}\" \
        -nb \"#{bg_color}\" \
        -sb \"#{sel_bg_color}\" \
        -sf \"#{sel_fg_color}\" \
        -i -l #{height} \
        -w \"#{width}\" \
        -fn \"#{font}\" " + (if line_height.nil? then "" else "-lh " + line_height.to_s end)

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
    def self.alignr(lhs, r, w)
        x = r
        str = lhs + x
        while str.width < w
            x = '.' + x
            str = lhs + x
        end
        str
    end
    def self.scrunch(str, size, dots='...')
        puts("scrunching #{str} to #{size}")
        if str.nil?
            nil
        elsif str.width < size
            str
        else
            middle = str.length / 2
            # Not centered; intentional
            lhs = str[0..middle]
            rhs = str[-middle..-1]
            lr = false
            while str.width > size
                if lr
                    lhs = lhs[0..-2]
                else
                    rhs = rhs[1..-1]
                end
                lr = !lr
                str = lhs + dots + rhs
                puts("scrunching width="+ str.width.to_s)
            end
            str
        end
    end
end
