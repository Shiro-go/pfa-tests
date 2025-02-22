function tests_pricer()
    format long;
    clear all;
    clc;

    % ANSI color codes for terminal text formatting
    RED     = "\033[31m";
    GREEN   = "\033[32m";
    YELLOW  = "\033[33m";
    BLUE    = "\033[34m";
    MAGENTA = "\033[35m";
    CYAN    = "\033[36m";
    WHITE   = "\033[37m";

    DIM     = "\033[2m";
    RESET   = "\033[0m";

    fprintf([BLUE, "Tests made for PFA @EPITA\n", WHITE, "Contributors :\n", RESET, "   - Shiro G. (ST1)\n   - Eliott L. (C2)\n"]);
    fprintf([BLUE, "[DISCLAIMER] ", RED, "Tests are made by student, and are not by any mean official, please refer to the official moulinette for sure tests\n\n\n", RESET]);

    fprintf([CYAN, "### RUNNING TESTS ###\n\n", RESET]);

    close_factor    = 1e-2;     % how close you have to be
    number_of_tests = 0;        % increments for each tests
    nb_correct      = 0;

    % update the score
    function upd_score(correct)
        if correct
            nb_correct = nb_correct+1;
        end
        number_of_tests = number_of_tests+1;
    end

    % Helper functions for colored output
    function print_result(name, success)
        if success
            fprintf([GREEN, "[SUCESS]: ", RESET, name, "\n"]);
        else
            fprintf([RED, "[FAIL]: ", RESET, name, "\n"]);
        end
        upd_score(success);
    end
    function assert_in_range(name, current, expected)
        if abs(current-expected)<close_factor
            print_result([name], 1);
        else
            print_result([name, DIM, "\n      - current  : ", WHITE, num2str(current), DIM, "\n      - expected : ", WHITE, num2str(expected), RESET], 0);
        end
    end
    function assert_lists(name, current, expected)
        if ~isequal(size(current), size(expected))
            print_result(name, 0)
            return;
        end
        print_result(name, all(all(abs(current - expected) < close_factor)));
    endfunction
    
    try
        fprintf([MAGENTA, "=====       f_logN TESTS      =====\n", RESET]);
        % Test 1: Standard Case (m=0, s=1)
        expected = [9.90238e-04 2.81590e-01 3.98942e-01 2.18507e-02 2.81590e-03 3.79083e-06 9.90238e-08];
        value = pricer.f_logN(0, 1, [0.01, 0.1, 1, 5, 10, 50, 100]);
        assert_lists("Standard Case (m=0, s=1)", value, expected)
        % Test 2: Mean Shift (m=1, s=1)
        expected = [1.70793e-02 2.41970e-01 1.46777e-01 1.70793e-02 6.00610e-06];
        value = pricer.f_logN(1, 1, [0.1, 1, 2.718, 10, 100]);
        assert_lists("Mean Shift (m=1, s=1)", value, expected)
        % Test 3: Higher Spread (m=0, s=2)
        expected = [1.02815e+00 1.99471e-01 1.02815e-02 1.40795e-04];
        value = pricer.f_logN(0, 2, [0.1, 1, 10, 100]);
        assert_lists("Higher Spread (m=0, s=2)", value, expected)
        % Test 4: Edge Cases
        value = pricer.f_logN(0, 1, [0, -1, NaN, Inf]);
        print_result("Edge Cases", value(1) == 0 && isnan(value(2)) && isnan(value(3)) && value(4) == 0)
        % Test 5: Very Small s=0.1
        expected = [2.96247e-114 3.98942e+00 2.96247e-116];
        value = pricer.f_logN(0, 0.1, [0.1, 1, 10]);
        assert_lists("Very Small s=0.1", value, expected)

        fprintf([MAGENTA, "=====         Phi TESTS       =====\n", RESET]);
        assert_in_range("Phi(0)", Phi(pricer, 0), 0.5)
        assert_in_range("Phi(1)", Phi(pricer, 1), 0.84134)
        assert_in_range("Phi(2)", Phi(pricer, 2), 0.97724)
        assert_in_range("Phi(3)", Phi(pricer, 3), 0.99865)
        assert_in_range("Phi(4)", Phi(pricer, 4), 0.99996)
        assert_in_range("Phi(-1)", Phi(pricer, -1), 0.15865)

        fprintf([MAGENTA, "=====     price_call TESTS    =====\n", RESET]);
        % Test 1: Standard Case (S0=100, T=1, K=100, m=0, s=1)
        value = price_call(pricer, 100, 1, 100, 0, 1);
        expected = 38.29241;
        assert_in_range("Standard Case (S0=100, T=1, K=100, m=0, s=1)", value, expected);
        % Test 2: Deep In-The-Money Call (S0=150, T=1, K=100, m=0, s=1)
        value = price_call(pricer, 150, 1, 100, 0, 1);
        expected = 76.37411;
        assert_in_range("Deep In-The-Money Call (S0=150, T=1, K=100, m=0, s=1)", value, expected);
        % Test 3: Deep Out-Of-The-Money Call (S0=50, T=1, K=100, m=0, s=1)
        value = price_call(pricer, 50, 1, 100, 0, 1);
        expected = 9.53022;
        assert_in_range("Deep Out-Of-The-Money Call (S0=50, T=1, K=100, m=0, s=1)", value, expected);
        % Test 4: High Volatility (S0=100, T=1, K=100, m=0, s=2)
        value = price_call(pricer, 100, 1, 100, 0, 2);
        expected = 68.26854;
        assert_in_range("High Volatility (S0=100, T=1, K=100, m=0, s=2)", value, expected);
        % Test 5: Long-Term Option (S0=100, T=5, K=100, m=0, s=1)
        value = price_call(pricer, 100, 5, 100, 0, 1);
        expected = 73.64425;
        assert_in_range("Long-Term Option (S0=100, T=5, K=100, m=0, s=1)", value, expected);
        % Test 6: Short-Term Option (S0=100, T=0.1, K=100, m=0, s=1)
        value = price_call(pricer, 100, 0.1, 100, 0, 1);
        expected = 12.56329;
        assert_in_range("Short-Term Option (S0=100, T=0.1, K=100, m=0, s=1)", value, expected);
        % Test 7: Low Strike Price (S0=100, T=1, K=50, m=0, s=1)
        value = price_call(pricer, 100, 1, 50, 0, 1);
        expected = 59.53022;
        assert_in_range("Low Strike Price (S0=100, T=1, K=50, m=0, s=1)", value, expected);
        % Test 8: High Strike Price (S0=100, T=1, K=200, m=0, s=1)
        value = price_call(pricer, 100, 1, 200, 0, 1);
        expected = 19.06045;
        assert_in_range("High Strike Price (S0=100, T=1, K=200, m=0, s=1)", value, expected);
        % Test 9: Edge Case - Zero Volatility (S0=100, T=1, K=100, m=0, s=0.01)
        value = price_call(pricer, 100, 1, 100, 0, 0.01);
        expected = 0.39894;
        assert_in_range("Edge Case - Zero Volatility (S0=100, T=1, K=100, m=0, s=0.01)", value, expected);
        % Test 10: Edge Case - Very Long-Term Option (S0=100, T=20, K=100, m=0, s=1)
        value = price_call(pricer, 100, 20, 100, 0, 1);
        expected = 97.46465;
        assert_in_range("Edge Case - Very Long-Term Option (S0=100, T=20, K=100, m=0, s=1)", value, expected);


        fprintf([MAGENTA, "=====     price_put TESTS     =====\n", RESET]);
        % Test 1: Standard Case (S0=100, T=1, K=100, m=0, s=1)
        value = price_put(pricer, 100, 1, 100, 0, 1);
        expected = 38.29241;
        assert_in_range("Standard Case (S0=100, T=1, K=100, m=0, s=1)", value, expected);
        % Test 2: Deep In-The-Money Put (S0=50, T=1, K=100, m=0, s=1)
        value = price_put(pricer, 50, 1, 100, 0, 1);
        expected = 59.53022;
        assert_in_range("Deep In-The-Money Put (S0=50, T=1, K=100, m=0, s=1)", value, expected);
        % Test 3: Deep Out-Of-The-Money Put (S0=150, T=1, K=100, m=0, s=1)
        value = price_put(pricer, 150, 1, 100, 0, 1);
        expected = 26.37411;
        assert_in_range("Deep Out-Of-The-Money Put (S0=150, T=1, K=100, m=0, s=1)", value, expected);
        % Test 4: High Volatility (S0=100, T=1, K=100, m=0, s=2)
        value = price_put(pricer, 100, 1, 100, 0, 2);
        expected = 68.26854;
        assert_in_range("High Volatility (S0=100, T=1, K=100, m=0, s=2)", value, expected);
        % Test 5: Long-Term Option (S0=100, T=5, K=100, m=0, s=1)
        value = price_put(pricer, 100, 5, 100, 0, 1);
        expected = 73.64425;
        assert_in_range("Long-Term Option (S0=100, T=5, K=100, m=0, s=1)", value, expected);
        % Test 6: Short-Term Option (S0=100, T=0.1, K=100, m=0, s=1)
        value = price_put(pricer, 100, 0.1, 100, 0, 1);
        expected = 12.56329;
        assert_in_range("Short-Term Option (S0=100, T=0.1, K=100, m=0, s=1)", value, expected);
        % Test 7: Low Strike Price (S0=100, T=1, K=50, m=0, s=1)
        value = price_put(pricer, 100, 1, 50, 0, 1);
        expected = 9.53022;
        assert_in_range("Low Strike Price (S0=100, T=1, K=50, m=0, s=1)", value, expected);
        % Test 8: High Strike Price (S0=100, T=1, K=200, m=0, s=1)
        value = price_put(pricer, 100, 1, 200, 0, 1);
        expected = 119.06045;
        assert_in_range("High Strike Price (S0=100, T=1, K=200, m=0, s=1)", value, expected);
        % Test 9: Edge Case - Zero Volatility (S0=100, T=1, K=100, m=0, s=0.01)
        value = price_put(pricer, 100, 1, 100, 0, 0.01);
        expected = 0.39894;
        assert_in_range("Edge Case - Zero Volatility (S0=100, T=1, K=100, m=0, s=0.01)", value, expected);
        % Test 10: Edge Case - Very Long-Term Option (S0=100, T=20, K=100, m=0, s=1)
        value = price_put(pricer, 100, 20, 100, 0, 1);
        expected = 97.46465;
        assert_in_range("Edge Case - Very Long-Term Option (S0=100, T=20, K=100, m=0, s=1)", value, expected);

        fprintf([MAGENTA, "=====     f_sum_logN TESTS    =====\n", RESET]);
        % Test 1: Standard Case (m=0, s=1, x=[0.1, 1, 5, 10])
        value = f_sum_logN(pricer, 0, 1, [0.1, 1, 5, 10]);
        expected = [3.61306e-04 2.62422e-01 6.63391e-02 9.33204e-03];
        assert_in_range("Standard Case (m=0, s=1, x=[0.1, 1, 5, 10])", value, expected);
        % Test 2: Different Mean (m=1, s=1, x=[0.1, 1, 2.718, 10, 100])
        value = f_sum_logN(pricer, 1, 1, [0.1, 1, 2.718, 10, 100]);
        expected = [2.97452e-07 1.96293e-02 9.65336e-02 4.53668e-02 1.51246e-05];
        assert_in_range("Different Mean (m=1, s=1, x=[0.1, 1, 2.718, 10, 100])", value, expected);
        % Test 3: High Volatility (m=0, s=2, x=[0.1, 1, 10, 100])
        value = f_sum_logN(pricer, 0, 2, [0.1, 1, 10, 100]);
        expected = [1.55322e-01 1.82255e-01 1.88519e-02 1.96093e-04];
        assert_in_range("High Volatility (m=0, s=2, x=[0.1, 1, 10, 100])", value, expected);
        % Test 4: Edge Cases (m=0, s=1, x=[0, -1, NaN, Inf])
        value = f_sum_logN(pricer, 0, 1, [0, -1, NaN, Inf]);
        print_result("Edge Cases (m=0, s=1, x=[0, -1, NaN, Inf])", value(1) == 0 && isnan(value(2)) && isnan(value(3)) && value(4) == 0)
        % Test 5: Very Small s (m=0, s=0.1, x=[0.1, 1, 10])
        value = f_sum_logN(pricer, 0, 0.1, [0.1, 1, 10]);
        expected = [0 5.90359e-21 1.22272e-103];
        assert_in_range("Very Small s (m=0, s=0.1, x=[0.1, 1, 10])", value, expected);

        fprintf([MAGENTA, "=====         F_S TESTS       =====\n", RESET]);
        % Test 1: Standard Case (p=[0.3, 0.4, 0.3], m=0, s=1, x=[0.1, 1, 5, 10])
        value = F_S(pricer, [0.3, 0.4, 0.3], 0, 1, [0.1, 1, 5, 10]);
        expected = [0.30426 0.53403 0.92688 0.98576];
        assert_in_range("Standard Case (p=[0.3, 0.4, 0.3], m=0, s=1, x=[0.1, 1, 5, 10])", value, expected);
        % Test 2: Different Probabilities (p=[0.1, 0.6, 0.3], m=0, s=1, x=[0.1, 1, 5, 10])
        value = F_S(pricer, [0.1, 0.6, 0.3], 0, 1, [0.1, 1, 5, 10]);
        expected = [0.10639 0.43403 0.91615 0.9837];
        assert_in_range("Different Probabilities (p=[0.1, 0.6, 0.3], m=0, s=1, x=[0.1, 1, 5, 10])", value, expected);
        % Test 3: High Variance (p=[0.3, 0.4, 0.3], m=0, s=2, x=[0.1, 1, 10, 100])
        value = F_S(pricer, [0.3, 0.4, 0.3], 0, 2, [0.1, 1, 10, 100]);
        expected = [0.35242 0.55777 0.83746 0.78937];
        assert_in_range("High Variance (p=[0.3, 0.4, 0.3], m=0, s=2, x=[0.1, 1, 10, 100])", value, expected);
        % Test 4: Edge Cases (p=[0.3, 0.4, 0.3], m=0, s=1, x=[0, -1, NaN, Inf])
        value = F_S(pricer, [0.3, 0.4, 0.3], 0, 1, [0, -1, NaN, Inf]);
        print_result("Edge Cases (p=[0.3, 0.4, 0.3], m=0, s=1, x=[0, -1, NaN, Inf])", value(1) == 0.3 && isnan(value(2)) && isnan(value(3)) && isnan(value(4)))
        % Test 5: Very Small s (p=[0.3, 0.4, 0.3], m=0, s=0.1, x=[0.1, 1, 10])
        value = F_S(pricer, [0.3, 0.4, 0.3], 0, 0.1, [0.1, 1, 10]);
        expected = [0.3 0.5 1];
        assert_in_range("Very Small s (p=[0.3, 0.4, 0.3], m=0, s=0.1, x=[0.1, 1, 10])", value, expected);

        fprintf("\n\n");
        
        fprintf([CYAN, "### ALL TESTS COMPLETED ###\n", RESET]);

        fprintf([WHITE, "Your note : "]);

        if (nb_correct == number_of_tests)
            fprintf([GREEN, "100p\n\n\n"]);
        else
            format short;
            fprintf([YELLOW, num2str(round(nb_correct/number_of_tests*100)), "p\n\n\n"]);
        end
    catch ME
        fprintf("\033[31m[ERROR]\033[0m Test failed: %s\n", ME.message);
    end
        fprintf([RESET])

end
