require 'active_support/all'

#"注意：sortの関係で色の並び順が本来のタギロンと違い、青が左で赤が右になっています。"
#"0は偶数です。"

class Card

    def initialize
        @cards = [[0, "r"], [0, "b"], [1, "r"], [1, "b"], [2, "r"], [2, "b"], [3, "r"], [3, "b"], [4, "r"], [4, "b"], [5, "g"], [5, "g"], [6, "r"], [6, "b"], [7, "r"], [7, "b"], [8, "r"], [8, "b"], [9, "r"], [9, "b"]]
        @player1_card = []
        @player2_card = []
        @deck_card = []
        @action = String
        @is_player1_turn = false
        @turn_count = 1
    end

    def draw
        draw_card = (0..19).to_a.sample(16)
        draw_card.each_with_index do |d,i|
            if i < 5
                @player1_card << @cards[d]
            elsif i < 10
                @player2_card << @cards[d]
            else
                @deck_card << @cards[d]
            end
        end
        @player1_card.sort!
        @player2_card.sort!
        @deck_card.sort!
        return @player1_card,@player2_card,@deck_card
    end


    def all_cards
        return @player1_card, @player1_card,@deck_card
    end
    def player1_card
        @player1_card
    end
    def player2_card
        @player1_card
    end
    def deck_card
        @deck_card
    end

    def show_card(who,card)
        puts("#{who}を開示します。準備ができたら、1を入力してください。")
        select_action
        fail_action until @action == 1
        print_underbar
        return_card_view(card)
        print_underbar
        puts("確認ができたら0を入力してください。")
        select_action
        fail_action until @action == 0
        puts("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
    end

    def return_card_view(card)
        card.each_with_index do |c,i|
            if c[1] == "r"
                print("赤の#{c[0]}")
            elsif c[1] == "b"
                print("青の#{c[0]}")
            else
                print("緑の#{c[0]}")
            end
            i ==  card.length-1 ? puts("") : print(",")
        end
    end

    def print_underbar
        puts("----------------------------------")
    end

    def select_action
        print("入力:")
        @action = String
        @action = gets.to_i
    end

    def fail_action
        puts("無効な値です。")
        print("入力:")
        @action = gets.to_i
    end

    def start
        draw
        show_card("プレイヤー1の手札",@player1_card)
        show_card("プレイヤー2の手札",@player2_card)
        show_card("台札",@deck_card)
        turn
    end

    def turn
        @is_player1_turn = !(@is_player1_turn)
        @is_player1_turn ? puts("\n第#{@turn_count}ターン\nプレイヤー１は相手に質問しますか？(1) それとも、数字を当てますか？(0)") : puts("プレイヤー２は相手に質問しますか？(1) それとも、数字を当てますか？(0)")
        @is_player1_turn ? @target_card = @player2_card : @target_card = @player1_card
        select_action
        fail_action until @action == 1 || @action == 0
        print_underbar
        @action == 1 ? question : answer
    end

    def question
        select_questions
        print_underbar
        select_action
        fail_action until @@questions[@action-1].present?
        puts("選んだ質問:#{@@questions[@action-1][0]}")
        q_init
        self.send("q_#{@@questions[@action-1][1]}",@target_card)
        @@questions.delete_at(@action-1)
        print_underbar
        turn
    end

    @@questions = [
        ["1or2",0],["3or4",1],["6or7",2],["8or9",3],["連番になっているところは？",4],["連続して隣り合っている色はどこ？",5],
        ["偶数は何枚ある？",6],["奇数は何枚ある？",7],["赤は何枚ある？",8],["青は何枚ある？",9],["0はどこ？",10],
        ["5はどこ？",11],["左の３つの合計は？",12],["中央の３つの合計は？",13],["右の３つの合計は？",14],["赤の合計はいくつ？",15],
        ["青の合計はいくつ？",16],["同じ数字のペアはいくつある？",17]
    ]

    def select_questions
        @@questions.each_with_index do |q,i|
            printf('%02d :',i+1)
            puts q[0]
        end
        puts("質問を選んでください。")
    end

    def q_init
        @num_ans = 0
        @ans = []
        @ans_sub = []
        @color_ary = []
        @cnt = 1
        @start_index = 0
    end

    def q_0(target_card)
        serch_index(1,2,target_card)
    end

    def q_1(target_card)
        serch_index(3,4,target_card)
    end

    def q_2(target_card)
        serch_index(6,7,target_card)
    end

    def q_3(target_card)
        serch_index(8,9,target_card)
    end

    def q_4(target_card)
        target_card.each { |n| @ans_sub << n[0]}
        start_num = @ans_sub[0]
        p @ans_sub
        @ans_sub.each_with_index do |num,i|
            if i == 0
                @cnt += 1
                next
            end
            if num == start_num+1
                @cnt += 1
                if i == @ans_sub.length && @cnt >= 2
                    @ans << [start_num,i]
                end
                if num != @ans_sub[i+1]
                    @ans << [@start_index,i]
                    @start_index = i+1
                    start_color = @ans_sub[i+1]
                    @cnt = 0
                end
            end
            if num != start_num
                @start_index = i
                start_num = num
                @cnt = 0
            end
        end
        if @ans.length == 0
            puts("連続する数字がある場所はありません。")
        else
            print("左から数えて")
            tmp = nil
            @ans.each_with_index do |n,i|
                if tmp.nil?
                    tmp = n[1]
                    next
                end
                if tmp == n[0]
                    @ans[i-1][1] = n[1]
                    @ans.delete_at(i)
                    tmp = nil
                elsif tmp != n[0]
                    tmp = n[1]
                end
                
            end
            @ans.each { |n| print("#{n[0]+1}番目から#{n[1]+1}番目まで  ") }
            print("は連続する数字です。\n")
        end
    end

    def q_5(target_card)
        target_card.each { |n| @ans_sub << n[1]}
        start = @ans_sub[0]
        p @ans_sub
        @ans_sub.each_with_index do |color,i|
            if i == 0
                @cnt += 1
                next
            end
            if color == start
                @cnt += 1
                if i == @ans_sub.length && @cnt >= 2
                    @ans << [start,i]
                end
                if color != @ans_sub[i+1]
                    @ans << [@start_index,i]
                    @start_index = i+1
                    start_color = @ans_sub[i+1]
                    @cnt = 0
                end
            end
            if color != start
                @start_index = i
                start = color
                @cnt = 0
            end
        end
        if @ans.length == 0
            puts("色が連続して隣り合うところはありません。")
        else
            print("左から数えて")
            @ans.each { |n| print("#{n[0]+1}番目から#{n[1]+1}番目まで ") }
            print("は同じ色が隣り合う場所です。\n")
        end
    end

    def q_6(target_card)
        odd_or_even(target_card,0,"偶数")
    end

    def q_7(target_card)
        odd_or_even(target_card,1,"奇数")
    end

    def q_8(target_card)
        count_color_card(target_card,"r")
    end

    def q_9(target_card)
        count_color_card(target_card,"b")
    end

    def q_10(target_card)
        serch_by_a_number(target_cards,0)
    end

    def q_11(target_card)
        serch_by_a_number(target_cards,5)
    end

    def q_12(target_card)
        sum_3_number(target_card,0,2,"左")
    end

    def q_13(target_card)
        sum_3_number(target_card,1,3,"中央")
    end

    def q_14(target_card)
        sum_3_number(target_card,2,4,"右")
    end

    def q_15(target_card)
        sum_all_same_color(target_card,"r","赤")
    end

    def q_16(target_card)
        sum_all_same_color(target_card,"b","青")
    end

    def q_17(target_card)
        target_card.each { |n| @ans_sub << n[0]}
        start_num = @ans_sub[0]
        start_index = 0
        @ans_sub.each_with_index do |num,i|
            if i == 0
                @cnt += 1
                next
            end
            if num == start_num
                @cnt += 1
                if i == @ans_sub.length && @cnt >= 2
                    @ans.push([start_index,i])
                end
                if num != @ans_sub[i+1]
                    @ans << [start_index,i]
                    start_index = i+1
                    start_num = @ans_sub[i+1]
                    @cnt = 0
                end
            end
            if num != start_num
                start_index = i
                start_num = num
                @cnt = 0
            end
        end
        if @ans.length == 0
            puts("同じ数字のペアはありません。")
        else
            puts("同じ数字のペアは#{@ans.length}個あります。")
        end
    end

    def sum_all_same_color(target_card,color,string)
        @target_cards.each { |n| @num_ans += n[0] if n[1] == "#{color}"}
        puts("#{string}のカードの合計は#{@num_ans}です。")
    end

    def sum_3_number(target_card,start_index,last_index,string)
        target_card.each_with_index { |n,i| @num_ans += n[0] if i >= start_index && i <= last_index}
        puts("#{string}枚のカードの合計は#{@num_ans}です。")
    end

    def serch_by_a_number(target_card,num)
        target_card.each_with_index { |n,i| q_ary << i if n[0] == num }
        if q_ary.length == 0
            puts("#{num}のカードはありません。")
        elsif q_ary.length == 1
            puts("#{num}のカードは左から#{q_ary[0]+1}番目にあります。")
        elsif q_ary.length == 2
            puts("#{num}のカードは左から#{q_ary[0]+1}番目と#{q_ary[1]+1}番目にあります。")
        end
    end

    def count_color_card(target_card,string)
        @ans = target_card.select { |n| n[1] == string}
        string == "r" ? puts("赤のカードは#{@ans.length}枚あります。") : puts("青のカードは#{@ans.length}枚あります。")
    end

    def odd_or_even(target_card,num,string)
        @ans = target_card.select { |n| n[0] % 2 == 0}
        @ans == 0 ? puts("#{string}のカードはありません。") : puts("#{string}のカードは#{@ans.length}枚あります。")
    end

    def serch_index(num1,num2,target_card)
        puts("#{num1}と#{num2}どちらを探しますか？")
        select_action
        fail_action until @action == num1 || @action == num2
        target_card.each_with_index { |n,i| @ans << i if n[0] == @action }
        if @ans.length == 0
            puts("#{@action}のカードはありません。")
        elsif @ans.length == 1
            puts("#{@action}のカードは左から#{@ans[0]+1}番目にあります。")
        elsif @ans.length == 2
            puts("#{@action}のカードは左から#{@ans[0]+1}番目と#{@ans[1]+1}番目にあります。")
        end
    end

    def answer
        ans_init
        guess_ans
        show_guess_ary
        check_answer
    end

    def ans_init
        @answer_ary = Array.new(5).map{Array.new(2)}
    end

    def guess_ans
        @answer_ary.each_with_index do |ary,i|
            puts("左から#{t+1}番目の数字は？")
            print("入力:")
            ary[i][0] = gets.to_i
            until ary[i][0] == 0 || ary[i][0] == 1 || ary[i][0] == 2 || ary[i][0] == 3 || ary[i][0] == 4 || ary[i][0] == 5 || ary[i][0] == 6 || ary[i][0] == 7 || ary[i][0] == 8 || ary[i][0] == 9
                puts("無効な値です。")
                print("入力:")
                ary[i][0] = gets.to_i
            end
            if ary[i][0] != 5
                puts("色は？（赤:r , 青:b）")
                print("入力:")
                ary[i][1] = gets.to_s.chomp
                until ary[i][1] == "r" || ary[i][1] == "b"
                    puts("無効な値です。")
                    print("入力:")
                    ary[i][1] = gets.to_s.chomp
                end
            else
                ary[i][1] = "g"
            end
        end
        return @answer_ary
    end

    def show_guess_ary
        puts("入力した値は")
        @answer_ary.each_with_index do |a,i|
            case a[1]
            when "r"
                print("赤の#{a[0]} ")
            when "b"
                print("青の#{a[0]} ")
            when "g"
                print("緑の#{a[0]} ")
            end
        end
        puts("です。")
    end

    def check_answer
        if @answer_ary == @target_card
            @is_player1_turn ? bingo_answer("1") : bingo_answer("2")
        else
            puts("不正解！間違っています！")
            turn
        end
            
    end

    def bingo_answer(player)
        print_underbar
        puts("正解！プレイヤー#{player}の勝利です")
        puts("プレイヤー1のカード")
        return_card_view(@player1_card)
        puts("プレイヤー2のカード")
        return_card_view(@player2_card)
    end

end

Card.new.start