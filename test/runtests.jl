using PreallocatedArrays
using Test

function test1()
    a = rand(3, 3)
    blockvec = PreallocatedArray(a; num=4, haslabel=false)
    a1, id1 = get_block(blockvec)
    a1 .= ones(3, 3)
    a2, id2 = get_block(blockvec)
    a2 .= ones(3, 3) * 2
    display(blockvec)
    println("---------------------")

    unused!(blockvec, id1)
    display(blockvec)
    println("---------------------")
    b, ids = get_block(blockvec, 3)
    b[1] .= ones(3, 3) * 3
    b[2] .= ones(3, 3) * 4
    display(blockvec)

    return true
end

function test2()
    println("---------------------")
    a = rand(10)
    blockvec2 = PreallocatedArray(a; num=4, haslabel=false)
    t, i = get_block(blockvec2)
    t .= ones(10)
    display(blockvec2)
    println("---------------------")

    a = rand(10)
    blockvec2 = PreallocatedArray(a; num=4, haslabel=true)
    t, i = new_block_withlabel(blockvec2, "cat")
    t .= ones(10) * 100
    display(blockvec2)
    println("---------------------")

    t2, i2 = new_block_withlabel(blockvec2, "dog")
    t2 .= zeros(10)
    display(blockvec2)
    println("---------------------")

    unused!(blockvec2, i2)
    t3, i3 = new_block_withlabel(blockvec2, "bird")
    t3 .= ones(10)
    display(blockvec2)


    t4, i4 = load_block_withlabel(blockvec2, "bird")
    display(t4)

    t4, i4 = load_block_withlabel(blockvec2, "cat")
    display(t4)



    println("---------------------")
    a = rand(10)
    blockvec2 = PreallocatedArray(a; labeltype=Symbol, num=4, haslabel=true)
    t, i = new_block_withlabel(blockvec2, :cat)
    t .= ones(10) * 120
    display(blockvec2)

    t4, i4 = load_block_withlabel(blockvec2, :cat)
    display(t4)
    println("---------------------")

    return true
end

function test3()
    data = Vector{Float64}[]
    for i = 1:10
        push!(data, rand(4))
    end
    blockvec = PreallocatedArray(data)
    display(blockvec)

    data2 = Vector{Float64}[]
    labels = String[]
    for i = 1:10
        push!(data2, rand(8))
        push!(labels, "$(i)-th")
    end
    blockvec2 = PreallocatedArray(data, labels)
    display(blockvec2)

    return true
end

function test4()
    a = rand(10)
    blockvec = PreallocatedArray(a)
    display(blockvec)
    b = blockvec[1]
    println(b)
    display(blockvec)
    c = blockvec[2]
    println(c)
    display(blockvec)

    blockvec2 = PreallocatedArray(a; num=4)
    d1 = blockvec2[1]
    println(d1)
    display(blockvec2)
    println("---------------------")
    d2 = blockvec2[2]
    println(d2)
    display(blockvec2)
    unused!(blockvec2, 2)
    println("---------------------")
    d3 = blockvec2[3]
    println(d3)
    display(blockvec2)
    println("---------------------")
    d6 = blockvec2[6]
    println(d6)
    display(blockvec2)
    println("---------------------")
    #vecd = blockvec2[3:10]

    return true
end

@testset "PreallocatedArrays.jl" begin
    # Write your tests here.
    println("---------------------")
    println("---------------------")
    println("test1")
    @test test1()

    println("---------------------")
    println("---------------------")
    println("test2")
    @test test2()

    println("---------------------")
    println("---------------------")
    println("test3")
    @test test3()

    println("---------------------")
    println("---------------------")
    println("test4")
    @test test4()

    println("---------------------")
    println("---------------------")
    println("bug: label expansion should not throw")
    @test begin
        a = rand(3, 3)
        blockvec = PreallocatedArray(a; num=1, haslabel=true)
        _, _ = new_block_withlabel(blockvec, "cat")
        # Second allocation expands storage but labels are not extended.
        _, _ = new_block_withlabel(blockvec, "dog")
        true
    end

    println("---------------------")
    println("---------------------")
    println("bug: labels should be preserved in vector constructor")
    @test begin
        data = [rand(4) for _ in 1:3]
        labels = ["a", "b", "c"]
        blockvec = PreallocatedArray(data, labels)
        blockvec._labels == labels
    end

    println("---------------------")
    println("---------------------")
    println("bug: unused! should clear label")
    @test begin
        a = rand(3, 3)
        blockvec = PreallocatedArray(a; num=1, haslabel=true)
        _, idx = new_block_withlabel(blockvec, "cat")
        unused!(blockvec, idx)
        blockvec._labels[idx] === nothing
    end

    println("---------------------")
    println("---------------------")
    println("bug: load_block_withlabel after unused should fail")
    @test_throws AssertionError begin
        a = rand(3, 3)
        blockvec = PreallocatedArray(a; num=1, haslabel=true)
        _, idx = new_block_withlabel(blockvec, "cat")
        unused!(blockvec, idx)
        load_block_withlabel(blockvec, "cat")
    end

    println("---------------------")
    println("---------------------")
    println("bug: load_block_withlabel should return assigned block")
    @test begin
        a = rand(2, 2)
        blockvec = PreallocatedArray(a; num=1, haslabel=true)
        # Force a mismatch between logical index and physical index.
        _ = blockvec[5]
        assigned_block, _ = new_block_withlabel(blockvec, "cat")
        loaded_block, _ = load_block_withlabel(blockvec, "cat")
        assigned_block === loaded_block
    end
end
