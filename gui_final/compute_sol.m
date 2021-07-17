function [sol] = compute_sol(F,rhs)
    sol = rskelf_sv(F,rhs);
end