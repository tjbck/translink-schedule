<script lang="ts">
	import { onMount } from 'svelte';
	import dayjs from 'dayjs';
	import relativeTime from 'dayjs/plugin/relativeTime';
	import customParseFormat from 'dayjs/plugin/customParseFormat';
	dayjs.extend(relativeTime);
	dayjs.extend(customParseFormat);

	const API_KEY = '';

	let estimates = [];
	let currentTime = dayjs();

	const getBusEstimate = async () => {
		console.log('getBusEstimate');

		const res = await fetch(
			`https://api.translink.ca/rttiapi/v1/stops/51862/estimates?apikey=${API_KEY}&timeframe=120`,
			{
				method: 'GET',
				headers: {
					Accept: 'application/json',
					'Content-Type': 'application/json'
				}
			}
		)
			.then(async (res) => {
				if (!res.ok) throw await res.json();
				return res.json();
			})
			.catch((error) => {
				console.log(error);
				return null;
			});

		if (res) {
			console.log(res);

			estimates = res
				.reduce((a, bus, i, arr) => {
					a.push(
						...bus.Schedules.map((schedule) => {
							return { ...schedule, RouteNo: bus.RouteNo, RouteName: bus.RouteName };
						})
					);
					return a;
				}, [])
				.sort(
					(a, b) => dayjs(a.ExpectedLeaveTime, 'hh:mma') - dayjs(b.ExpectedLeaveTime, 'hh:mma')
				);
		}
	};

	onMount(() => {
		getBusEstimate();
		setInterval(() => {
			getBusEstimate();
		}, 1000 * 60 * 2);

		setInterval(() => {
			currentTime = dayjs();
		}, 1000);
	});
</script>

<svelte:head>
	<title>Translink Schedule - SFU</title>
</svelte:head>

<div class=" text-center font-bold text-2xl py-5 bg-gray-800 text-neutral-200 flex justify-center">
	<div class="flex">
		<div class=" self-center mr-8">
			<img src="/translink.jpg" class=" w-14 h-14" />
		</div>

		<div class="self-center">
			{currentTime.format('hh:mm:ss a')}
		</div>
	</div>
</div>

<div class=" bg-gray-800 min-h-screen text-gray-100 flex justify-center">
	<div class=" max-w-5xl w-full">
		{#each estimates.filter((bus) => dayjs(bus.ExpectedLeaveTime, 'hh:mma') > currentTime) as bus}
			<div class="py-8 w-full">
				<div class="flex justify-between mx-10">
					<div class="flex">
						<!-- <div class="mr-8 self-center">
							<img src="/bus.png" class=" w-14 h-14" />
						</div> -->

						<div class=" self-center">
							<div class=" text-6xl font-bold">
								{bus.RouteNo}
							</div>
							<div class="mt-2 font-semibold">
								{bus.RouteName}
							</div>
						</div>
					</div>

					<div class=" font-semibold text-2xl flex flex-col">
						{dayjs(bus.ExpectedLeaveTime, 'hh:mma').from(currentTime, true)}
						<div class=" text-base text-right">
							{bus.ExpectedLeaveTime}
						</div>
					</div>
				</div>
			</div>
		{/each}
	</div>
</div>
