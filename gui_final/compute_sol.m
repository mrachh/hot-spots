function [sol] = compute_sol(F,rhs,invtype)
    if(invtype == 0)
        sol = rskelf_sv(F,rhs);
    else
        sol = F*rhs;
    end
end
