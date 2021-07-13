%include "../user-trampoline/trampoline.S"

make_trampoline nf1_decrement_ttl
make_trampoline nf2_one_way_nat
make_trampoline nf3_acl
make_trampoline nf4_maglev