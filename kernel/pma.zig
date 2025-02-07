/// Physical Memory Allocator
const Spinlock = @import("lock.zig").Spinlock;

pub const page_size: usize = 4096;

pub const BumpAllocator = struct {
    lock: Spinlock,
    heap_start: [*]u8,
    heap_size: usize,
    allocated: usize,

    pub fn init(heap_start: [*]u8, heap_size: usize) BumpAllocator {
        return .{
            .lock = Spinlock.init(),
            .heap_start = @ptrFromInt(alignUp(@intFromPtr(heap_start))),
            .heap_size = (heap_size / page_size) * page_size, // round down heap_size to the nearest multiple of page_size
            .allocated = 0,
        };
    }

    pub fn allocPages(self: *BumpAllocator, pages: usize) []u8 {
        const alloc_size = pages * page_size;

        self.lock.acquire(); // do i need to disable traps before ?
        if (self.allocated + alloc_size > self.heap_size) {
            @panic("out of memory");
        }
        const heap = self.heap_start[0..self.heap_size];
        const chunk = heap[self.allocated..][0..alloc_size];
        self.allocated += alloc_size;
        self.lock.release();

        return chunk;
    }

    pub inline fn pages_total(self: BumpAllocator) usize {
        return self.heap_size / page_size;
    }

    pub inline fn pages_used(self: BumpAllocator) usize {
        return self.allocated / page_size;
    }

    pub inline fn pages_free(self: BumpAllocator) usize {
        return (self.heap_size - self.heap_allocated) / page_size;
    }
};

inline fn alignUp(addr: usize) usize {
    return (addr + page_size - 1) & ~(page_size - 1);
}
