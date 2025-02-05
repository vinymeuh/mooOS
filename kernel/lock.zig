pub const Spinlock = struct {
    ticket: usize align(@sizeOf(usize)),
    serving: usize align(@sizeOf(usize)),

    pub fn init() Spinlock {
        return .{
            .ticket = 0,
            .serving = 0,
        };
    }

    pub fn acquire(lock: *Spinlock) void {
        const my_ticket = @atomicRmw(usize, &lock.ticket, .Add, 1, .monotonic);
        while (@atomicLoad(usize, &lock.serving, .acquire) != my_ticket) {}
    }

    pub fn release(lock: *Spinlock) void {
        const my_ticket = @atomicLoad(usize, &lock.serving, .monotonic);
        @atomicStore(usize, &lock.serving, my_ticket + 1, .release);
    }
};
