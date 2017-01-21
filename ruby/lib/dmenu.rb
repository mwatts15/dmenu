require 'open3'

class String
    def initialize
        super
        force_encoding("utf-8")
    end
end

module Dmenu
    require 'wcwidth'
    # Characters that, in the keyed fonts, are actually double width,
    # but not reported as such by wcwidth. This isn't an exhaustive list,
    # just characters I found by visually scanning some titles in my music
    # collection
    $DBL_CHARS = {'Noto Sans Mono CJK JP Regular' => '∞♥ⅢⅣ☆…→'}
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

        findex = font.index(':')
        base_font = font[0..(findex > 0 ? findex - 1 : -1)]
        repl_chars = $DBL_CHARS[base_font]
        res = ""
        lr_separation = 4
        textwidth = 2 * width / font_width - lr_separation
        if !repl_chars.nil?
            expr = %r{[^#{repl_chars}]+}
        end
        entries.collect! do |line|
            transformed_line = line.each_char.reject{|char| char.ord < 32 or (char.ord >= 0x7f and char.ord < 0xa0)}.inject(:+)
            s = if !transformed_line.nil?
                l, r = transformed_line.split("|||")
                loff = 0
                roff = 0
                if !repl_chars.nil?
                    loff = l.gsub(expr, "").length
                    roff =  r.nil? ? 0 : r.gsub(expr, "").length
                end
                scrunched = scrunch(r, [textwidth - l.width - lr_separation, textwidth / 2].max)
                r ? alignr(l, scrunched, textwidth - loff - roff) : l
            else
                $stderr.puts "Couldn't list #{line.inspect}"
                nil
            end
            s
        end.reject! {|x| x.nil? or x.empty? or x.match(/^\s+$/) }

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
            end
            str
        end
    end
end
