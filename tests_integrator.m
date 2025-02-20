function tests_integrator()
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

    fprintf([MAGENTA, "TO TEST YOUR CODE, SET PROPERTIES ACCESS TO PUBLIC IN INTEGRATOR\n(don't forget to set it back aftermath)\n\n", RESET]);

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
    function assert_integration(name, itg, f, a, b, n, expected)
        try
            assert_in_range(name, itg.integrate(f, a, b, n), expected);
        catch ME
            fprintf("\033[31m[ERROR]\033[0m %s, error: %s\n", name, ME.message);
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
        fprintf([MAGENTA, "=====    CONSTRUCTOR TESTS    =====\n", RESET]);
        % a01 : Basic construct
        itga01 = integrator("method", "left", "dx", 0.05);
        current = (strcmp(itga01.method, "left") && itga01.dx == 0.05);
        print_result("Constructor with arguments", current);
        % a02 : Default construct
        itga02 = integrator();
        current = (strcmp(itga02.method, "trapezes") && itga02.dx == 0.1);
        print_result("Constructor with no arguments", current);
        % a03 : Copy construct
        itga03 = integrator(itga01);
        current = (strcmp(itga03.method, "left") && itga03.dx == 0.05);
        print_result("Copy constructor", current);

        fprintf("\n");

        fprintf([MAGENTA, "=====      SET/GET TESTS      =====\n", RESET]);
        % b01 : set both once
        itgb01 = integrator();
        itgb01.set("method", "gauss2", "dx", 0.2);
        current = (strcmp(itgb01.method, "gauss2") && itgb01.dx == 0.2);
        print_result("Set method and dx", current);
        % b02 : set only method
        itgb03 = integrator();
        itgb03.set("method", "gauss2");
        current = (strcmp(itgb03.method, "gauss2"));
        print_result("Set method", current);
        % b03 : set both once
        itgb04 = integrator();
        itgb04.set("method", "gauss2", "dx", 0.1);
        current = (strcmp(itgb04.method, "gauss2") && itgb04.dx == 0.1);
        print_result("Set method and dx", current);
        % b04 : set only method
        itgb06 = integrator();
        itgb06.set("method", "gauss2");
        current = (strcmp(itgb06.method, "gauss2"));
        print_result("Set method", current);

        fprintf("\n");

        fprintf([MAGENTA, "=====    INTEGRATION TESTS    =====\n", RESET]);

        itg = integrator();

        fprintf([CYAN, "# LEFT\n", RESET]);
        itg.set("method", "left");
        assert_integration("Mouli - Left integration sin(x)", itg, @sin, 0, 3*pi/4, 5, 1.508790249679572);
        assert_integration("Mouli - Left integration exp(x)", itg, @exp, 1, -1, 5, -2.851738310472693);
        assert_integration("Left integration x", itg, @(x) x, 0, 1, 100, 0.5);
        assert_integration("Left integration exp(x) (a=-1, b=1)", itg, @exp, -1, 1, 5, 1.9116);
        assert_integration("Left integration x^2 (a=0, b=1)", itg, @(x) x.^2, 0, 1, 100, 1/3);
        assert_integration("Left integration sin (a=0, b=2*pi)", itg, @sin, 0, 2*pi, 100, 0);
        assert_integration("Left integration cos (a=0, b=2*pi)", itg, @cos, 0, 2*pi, 100, 0);
        assert_integration("Left integration xsin(x^2) (a=0, b=sqrt(pi))", itg, @(x) x .* sin(x.^2), 0, sqrt(pi), 100, 1);
        assert_integration("Left integration xe^x (a=0, b=1)", itg, @(x) x .* exp(x), 0, 1, 300, 1);

        fprintf([CYAN, "# RIGHT\n", RESET]);
        itg.set("method", "right");
        assert_integration("Mouli - Right integration sin(x)", itg, @sin, 0, 3*pi/4, 5, 1.842006470041450);
        assert_integration("Mouli - Right integration exp(x)", itg, @exp, 1, -1, 5, -1.911577355557652);
        assert_integration("Right integration x", itg, @(x) x, 0, 1, 100, 0.5);
        assert_integration("Right integration exp(x) (a=-1, b=1)", itg, @exp, -1, 1, 5, 2.85173831047269);
        assert_integration("Right integration x^2 (a=0, b=1)", itg, @(x) x.^2, 0, 1, 100, 1/3);
        assert_integration("Right integration sin (a=0, b=2*pi)", itg, @sin, 0, 2*pi, 100, 0);
        assert_integration("Right integration cos (a=0, b=2*pi)", itg, @cos, 0, 2*pi, 100, 0);
        assert_integration("Right integration xsin(x^2) (a=0, b=sqrt(pi))", itg, @(x) x .* sin(x.^2), 0, sqrt(pi), 100, 1);
        assert_integration("Right integration xe^x (a=0, b=1)", itg, @(x) x .* exp(x), 0, 1, 300, 1);

        fprintf([CYAN, "# MIDDLE\n", RESET]);
        itg.set("method", "middle");
        assert_integration("Mouli - Middle integration sin(x)", itg, @sin, 0, 3*pi/4, 5, 1.723005128722320);
        assert_integration("Mouli - Middle integration exp(x)", itg, @exp, 1, -1, 5, -2.334805854514639);
        assert_integration("Middle integration sin(x) (a=0, b=pi)", itg, @sin, 0, pi, 100, 2);

        fprintf([CYAN, "# TRAPEZES\n", RESET]);
        itg.set("method", "trapezes");
        assert_integration("Mouli - Trapeze integration sin(x)", itg, @sin, 0, 3*pi/4, 5, 1.675398359860511);
        assert_integration("Mouli - Trapeze integration exp(x)", itg, @exp, 1, -1, 5, -2.381657833015172);
        assert_integration("Trapezoidal integration x^2 (a=0, b=1)", itg, @(x) x.^2, 0, 1, 100, 1/3);
        assert_integration("Trapezoidal integration sin (a=0, b=2*pi)", itg, @sin, 0, 2*pi, 100, 0);
        assert_integration("Trapezoidal integration cos (a=0, b=2*pi)", itg, @cos, 0, 2*pi, 100, 0);
        assert_integration("Trapezoidal integration xsin(x^2) (a=0, b=sqrt(pi))", itg, @(x) x .* sin(x.^2), 0, sqrt(pi), 100, 1);
        assert_integration("Trapezoidal integration xe^x (a=0, b=1)", itg, @(x) x .* exp(x), 0, 1, 100, 1);
        
        fprintf([CYAN, "# SIMPSON\n", RESET]);
        itg.set("method", "simpson");
        assert_integration("Mouli - Simpson integration sin(x)", itg, @sin, 0, 3*pi/4, 5, 1.707136205768384);
        assert_integration("Mouli - Simpson integration exp(x)", itg, @exp, 1, -1, 5, -2.350423180681484);

        fprintf([CYAN, "# GAUSS2\n", RESET]);
        itg.set("method", "gauss2");
        assert_integration("Mouli - Gauss2 integration sin(x)", itg, @sin, 0, 3*pi/4, 5, 1.707087156152676);
        assert_integration("Mouli - Gauss2 integration exp(x)", itg, @exp, 1, -1, 5, -2.350388529424686);
        assert_integration("Gauss2 integration x", itg, @(x) x, 0, 1, 100, 0.5);
        assert_integration("Gauss2 integration x^2 (a=0, b=1)", itg, @(x) x.^2, 0, 1, 100, 1/3);
        assert_integration("Gauss2 integration sin (a=0, b=2*pi)", itg, @sin, 0, 2*pi, 100, 0);
        assert_integration("Gauss2 integration cos (a=0, b=2*pi)", itg, @cos, 0, 2*pi, 100, 0);
        assert_integration("Gauss2 integration xsin(x^2) (a=0, b=sqrt(pi))", itg, @(x) x .* sin(x.^2), 0, sqrt(pi), 100, 1);
        assert_integration("Gauss2 integration xe^x (a=0, b=1)", itg, @(x) x .* exp(x), 0, 1, 100, 1);

        fprintf([CYAN, "# GAUSS3\n", RESET]);
        itg.set("method", "gauss3");
        assert_integration("Mouli - Gauss3 integration sin(x)", itg, @sin, 0, 3*pi/4, 5, 1.707106790529971);
        assert_integration("Mouli - Gauss3 integration exp(x)", itg, @exp, 1, -1, 5, -2.350402382538070);
        
        fprintf([CYAN, "# ADDITIONAL\n", RESET]);

        itg.set("method", "gauss3");
        I = itg.integrate(@(x) exp(-x.^2), -1, 1, 100, []);
        expected = 1.4936;
        assert_in_range("Gauss3 integration exp(-x^2) over [-1,1]", I, expected);
        
        fprintf([CYAN, "# COMPLEX\n", RESET]);
        I = itg.integrate(@(x) log(1 + x), 0, 1, 100, []);
        expected = 0.3863;
        assert_in_range("Integration of log(1+x) over [0,1]", I, expected);
        
        I = itg.integrate(@(x) sqrt(x), 0, 1, 100, []);
        expected = 2/3;
        assert_in_range("Integration of sqrt(x) over [0,1]", I, expected);
        
        fprintf("\n");

        fprintf([MAGENTA, "=====     PRIMITIVE TESTS     =====\n", RESET]);

        y = itg.primitive(@(x) x.^2, 0, 1);
        expected = 1/3;
        assert_in_range("Primitive of x^2 from 0 to 1", y, expected);
        
        y = itg.primitive(@(x) cos(x), 0, pi/2);
        expected = 1;
        assert_in_range("Primitive of cos(x) from 0 to pi/2", y, expected);
        
        fprintf("\n");
        
        fprintf([MAGENTA, "===== INTEGRATION ERROR TESTS =====\n", RESET]);

        ns = [10, 20, 50, 100];
        s = itg.integration_error(@(x) x.^2, 0, 1, 1/3, ns, []);
        print_result("Integration error model", s(1) > 0 && s(2) > 0);
        
        s = itg.integration_error(@(x) exp(-x), 0, 1, 1 - exp(-1), ns, []);
        print_result("Integration error model for exp(-x)", s(1) > 0 && s(2) > 0);
        
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

