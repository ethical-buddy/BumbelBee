#ifndef WORKLOAD_H
#define WORKLOAD_H

enum workload_profile {
    WORKLOAD_PROFILE_NONE = 0,
    WORKLOAD_PROFILE_ATTACK = 1,
    WORKLOAD_PROFILE_SYSLOAD = 2,
    WORKLOAD_PROFILE_LIFECYCLE = 3
};

void workload_attack_sim(void);
void workload_sysload(void);
void workload_lifecycle_test(void);
int workload_run_profile(u32 profile_id);
int workload_has_active(void);
const char *workload_profile_name(u32 profile_id);

#endif
